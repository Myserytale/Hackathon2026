package com.digitalromania.farm;

import com.digitalromania.farm.models.Animal;
import com.digitalromania.farm.models.AuditLog;
import com.digitalromania.farm.models.Role;
import com.digitalromania.farm.models.User;
import com.digitalromania.farm.repositories.AnimalRepository;
import com.digitalromania.farm.repositories.AuditLogRepository;
import com.digitalromania.farm.repositories.UserRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
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

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@Transactional
public class IntegrationTests {

    @Autowired
    private WebApplicationContext webApplicationContext;

    private MockMvc mockMvc;

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

        User farmer = new User();
        farmer.setUsername("test_farmer");
        farmer.setPassword(passwordEncoder.encode("password123"));
        farmer.setRole(Role.FARMER);
        userRepository.save(farmer);
    }

    @Test
    void test2FAFlow() throws Exception {
        // Step 1: Login
        Map<String, String> loginRequest = Map.of("username", "test_farmer", "password", "password123");
        
        MvcResult loginResult = mockMvc.perform(post("/api/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(loginRequest)))
                .andExpect(status().isOk())
                .andReturn();
        
        Map<String, String> loginResponse = objectMapper.readValue(loginResult.getResponse().getContentAsString(), Map.class);
        String tempToken = loginResponse.get("token");
        assertThat(tempToken).isNotNull();
        
        // Step 2: Verify 2FA
        Map<String, String> verifyRequest = Map.of("tempToken", tempToken, "code", "123456");
        
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
    void testAuditLogCatchesDeletions() {
        Animal animal = new Animal();
        animal.setTagNumber("RO12345");
        animal.setSpecies("Cow");
        animal.setBreed("Holstein");
        animal.setBirthDate(LocalDate.now());
        animal.setOwnerId(1L);
        
        Animal savedAnimal = animalRepository.saveAndFlush(animal);
        
        // Delete
        animalRepository.delete(savedAnimal);
        animalRepository.flush();
        
        // Verify audit log
        List<AuditLog> logs = auditLogRepository.findAll();
        assertThat(logs).isNotEmpty();
        
        boolean hasDeleteLog = logs.stream()
                .anyMatch(log -> "DELETE".equals(log.getAction()) && "Animal".equals(log.getEntityName()));
        assertThat(hasDeleteLog).isTrue();
    }
}
