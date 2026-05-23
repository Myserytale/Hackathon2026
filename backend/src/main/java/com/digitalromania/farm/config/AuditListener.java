package com.digitalromania.farm.config;

import com.digitalromania.farm.models.AuditLog;
import com.digitalromania.farm.repositories.AuditLogRepository;
import jakarta.persistence.PostPersist;
import jakarta.persistence.PostRemove;
import jakarta.persistence.PostUpdate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Component;

import java.security.MessageDigest;
import java.time.LocalDateTime;
import java.util.Base64;

@Component
public class AuditListener {

    // Using @Lazy to avoid circular dependencies during JPA initialization
    @Autowired
    @Lazy
    private AuditLogRepository auditLogRepository;

    @PostPersist
    public void postPersist(Object entity) {
        logAction("CREATE", entity);
    }

    @PostUpdate
    public void postUpdate(Object entity) {
        logAction("UPDATE", entity);
    }

    @PostRemove
    public void postRemove(Object entity) {
        logAction("DELETE", entity);
    }

    private void logAction(String action, Object entity) {
        if (entity instanceof AuditLog) return; // Prevent infinite loop

        try {
            String entityName = entity.getClass().getSimpleName();
            
            // Hacky way to get ID for hackathon via reflection
            java.lang.reflect.Method getIdMethod = entity.getClass().getMethod("getId");
            Long entityId = (Long) getIdMethod.invoke(entity);

            String payload = entity.toString(); // For production use Jackson to JSON

            String rawData = action + entityName + entityId + payload + LocalDateTime.now();
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(rawData.getBytes("UTF-8"));
            String cryptographicHash = Base64.getEncoder().encodeToString(hash);

            AuditLog log = new AuditLog(null, entityName, entityId, action, payload, cryptographicHash, LocalDateTime.now(), "system_or_user");
            
            if(auditLogRepository != null) {
                auditLogRepository.save(log);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
