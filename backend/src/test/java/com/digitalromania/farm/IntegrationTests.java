package com.digitalromania.farm;

import com.digitalromania.farm.models.Animal;
import com.digitalromania.farm.models.AuditLog;
import com.digitalromania.farm.models.Role;
import com.digitalromania.farm.models.User;
import com.digitalromania.farm.repositories.AnimalRepository;
import com.digitalromania.farm.repositories.AuditLogRepository;
import com.digitalromania.farm.repositories.UserRepository;
import com.digitalromania.farm.services.TestEmailService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.context.WebApplicationContext;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

import org.springframework.cache.CacheManager;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.TestPropertySource;
import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@Import(IntegrationTests.CacheTestConfig.class)
@ActiveProfiles("test")
@TestPropertySource(properties = {
    "spring.datasource.url=jdbc:h2:mem:testdb;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE",
    "spring.datasource.driver-class-name=org.h2.Driver",
    "spring.datasource.username=sa",
    "spring.datasource.password=",
    "spring.jpa.database-platform=org.hibernate.dialect.H2Dialect",
    "spring.sql.init.mode=never"
})
@Transactional
public class IntegrationTests {

    @Autowired
    private WebApplicationContext webApplicationContext;

    private MockMvc mockMvc;

    @org.springframework.boot.test.context.TestConfiguration
    static class CacheTestConfig {
        @org.springframework.context.annotation.Bean
        @org.springframework.context.annotation.Primary
        CacheManager cacheManager() {
            return new org.springframework.cache.support.NoOpCacheManager();
        }
    }

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private AnimalRepository animalRepository;

    @Autowired
    private AuditLogRepository auditLogRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    private final ObjectMapper objectMapper = new ObjectMapper();

    @BeforeEach
    void setup() {
        mockMvc = MockMvcBuilders.webAppContextSetup(webApplicationContext).build();
        animalRepository.deleteAll();
        auditLogRepository.deleteAll();
        userRepository.deleteAll();
        TestEmailService.lastOtp = null;
        TestEmailService.lastRecipientEmail = null;

        User farmer = new User();
        farmer.setUsername("test_farmer");
        farmer.setName("Test Farmer");
        farmer.setEmail("test_farmer@demo.roeid.local");
        farmer.setPassword(passwordEncoder.encode("password123"));
        farmer.setRole(Role.FARMER);
        userRepository.save(farmer);
    }

    @Test
    void test2FAFlow() throws Exception {
        Map<String, String> loginRequest = Map.of(
                "email", "test_farmer@demo.roeid.local",
                "password", "password123",
                "expectedRole", "FARMER"
        );

        MvcResult loginResult = mockMvc.perform(post("/api/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(loginRequest)))
                .andExpect(status().isOk())
                .andReturn();

        Map<String, String> loginResponse = objectMapper.readValue(loginResult.getResponse().getContentAsString(), Map.class);
        String tempToken = loginResponse.get("token");
        assertThat(tempToken).isNotNull();
        assertThat(TestEmailService.lastOtp).isNotNull();

        Map<String, String> verifyRequest = Map.of("tempToken", tempToken, "code", TestEmailService.lastOtp);

        MvcResult verifyResult = mockMvc.perform(post("/api/auth/verify-2fa")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(verifyRequest)))
                .andExpect(status().isOk())
                .andReturn();

        Map<String, String> verifyResponse = objectMapper.readValue(verifyResult.getResponse().getContentAsString(), Map.class);
        String finalToken = verifyResponse.get("token");
        assertThat(finalToken).isNotNull();
    }

    @Test
    void testRegisterAndLoginAsFarmer() throws Exception {
        Map<String, String> registerRequest = Map.of(
                "username", "new_farmer",
                "name", "New Farmer",
                "email", "new_farmer@example.com",
                "password", "secret123",
                "role", "FARMER"
        );

        mockMvc.perform(post("/api/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(registerRequest)))
                .andExpect(status().isCreated());

        assertThat(userRepository.findByUsername("new_farmer")).isPresent();
        assertThat(userRepository.findByUsername("new_farmer").get().getRole()).isEqualTo(Role.FARMER);

        Map<String, String> loginRequest = Map.of(
                "email", "new_farmer@example.com",
                "password", "secret123",
                "expectedRole", "FARMER"
        );

        mockMvc.perform(post("/api/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(loginRequest)))
                .andExpect(status().isOk());
    }

    @Test
    void testFarmerCannotLoginToVetPortal() throws Exception {
        Map<String, String> loginRequest = Map.of(
                "email", "test_farmer@demo.roeid.local",
                "password", "password123",
                "expectedRole", "VET"
        );

        mockMvc.perform(post("/api/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(loginRequest)))
                .andExpect(status().isForbidden());
    }

    @Test
    void testDuplicateUsernameRegistration() throws Exception {
        Map<String, String> registerRequest = Map.of(
                "username", "test_farmer",
                "name", "Duplicate",
                "email", "other@example.com",
                "password", "secret123",
                "role", "FARMER"
        );

        mockMvc.perform(post("/api/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(registerRequest)))
                .andExpect(status().isConflict());
    }

    @Test
    void testAuditLogCatchesDeletions() {
        Animal animal = new Animal();
        animal.setTagNumber("RO12345");
        animal.setSpecies("Cow");
        animal.setBreed("Holstein");
        animal.setBirthDate(LocalDate.now());
        animal.setOwnerId(1L);

        Animal savedAnimal = animalRepository.saveAndFlush(animal);

        animalRepository.delete(savedAnimal);
        animalRepository.flush();

        List<AuditLog> logs = auditLogRepository.findAll();
        assertThat(logs).isNotEmpty();

        boolean hasDeleteLog = logs.stream()
                .anyMatch(log -> "DELETE".equals(log.getAction()) && "Animal".equals(log.getEntityName()));
        assertThat(hasDeleteLog).isTrue();
    }
}
