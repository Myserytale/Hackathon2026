package com.digitalromania.farm.controllers;

import com.digitalromania.farm.models.AuditLog;
import com.digitalromania.farm.repositories.AuditLogRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/audit")
public class AuditController {

    @Autowired
    private AuditLogRepository auditLogRepository;

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'SYSTEM')")
    public List<AuditLog> getAllAuditLogs() {
        return auditLogRepository.findAll();
    }

    @GetMapping(value = "/export", produces = "text/csv")
    @PreAuthorize("hasAnyRole('ADMIN', 'SYSTEM')")
    public ResponseEntity<String> exportAuditLogsAsCsv() {
        List<AuditLog> logs = auditLogRepository.findAll();
        StringBuilder csv = new StringBuilder();
        
        // Header
        csv.append("ID,Entity Name,Entity ID,Action,Cryptographic Hash,Timestamp,Performed By,Payload\n");
        
        // Rows
        for (AuditLog log : logs) {
            csv.append(log.getId()).append(",");
            csv.append(escapeSpecialCharacters(log.getEntityName())).append(",");
            csv.append(log.getEntityId()).append(",");
            csv.append(escapeSpecialCharacters(log.getAction())).append(",");
            csv.append(escapeSpecialCharacters(log.getCryptographicHash())).append(",");
            csv.append(log.getTimestamp()).append(",");
            csv.append(escapeSpecialCharacters(log.getPerformedBy())).append(",");
            csv.append(escapeSpecialCharacters(log.getPayload())).append("\n");
        }

        HttpHeaders headers = new HttpHeaders();
        headers.add(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=audit_ledger.csv");
        headers.add(HttpHeaders.CONTENT_TYPE, "text/csv; charset=utf-8");

        return ResponseEntity.ok()
                .headers(headers)
                .body(csv.toString());
    }
    
    private String escapeSpecialCharacters(String data) {
        if (data == null) return "";
        String escapedData = data.replaceAll("\\R", " ");
        if (escapedData.contains(",") || escapedData.contains("\"") || escapedData.contains("'")) {
            escapedData = escapedData.replace("\"", "\"\"");
            escapedData = "\"" + escapedData + "\"";
        }
        return escapedData;
    }
}
