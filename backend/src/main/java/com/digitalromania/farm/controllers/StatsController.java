package com.digitalromania.farm.controllers;

import com.digitalromania.farm.repositories.AnimalRepository;
import com.digitalromania.farm.repositories.IncidentRepository;
import com.digitalromania.farm.repositories.FundingApplicationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;

@RestController
@Tag(name = "Statistics", description = "Dashboard Statistics API")
@RequestMapping("/api/stats")
public class StatsController {

    @Autowired
    private AnimalRepository animalRepository;

    @Autowired
    private IncidentRepository incidentRepository;

    @Autowired
    private FundingApplicationRepository fundingApplicationRepository;

    @GetMapping("/dashboard")
    @Operation(summary = "Get Dashboard Stats", description = "Retrieves aggregated statistics for the main dashboards.")
    @PreAuthorize("hasAnyRole('ADMIN', 'VET', 'FARMER')")
    public ResponseEntity<Map<String, Object>> getDashboardStats() {
        Map<String, Object> stats = new HashMap<>();
        
        long totalAnimals = animalRepository.count();
        long activeIncidents = incidentRepository.findByStatus("OPEN").size();
        long pendingApplications = fundingApplicationRepository.findByStatus("PENDING").size();
        
        stats.put("totalAnimals", totalAnimals);
        stats.put("activeIncidents", activeIncidents);
        stats.put("pendingApplications", pendingApplications);
        
        return ResponseEntity.ok(stats);
    }
}
