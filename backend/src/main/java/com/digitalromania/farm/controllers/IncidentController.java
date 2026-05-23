package com.digitalromania.farm.controllers;

import com.digitalromania.farm.models.Incident;
import com.digitalromania.farm.repositories.IncidentRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/incidents")
public class IncidentController {

    @Autowired
    private IncidentRepository incidentRepository;

    @GetMapping
    public List<Incident> getAllIncidents() {
        return incidentRepository.findAll();
    }

    @GetMapping("/status/{status}")
    public List<Incident> getIncidentsByStatus(@PathVariable String status) {
        return incidentRepository.findByStatus(status);
    }

    @PostMapping
    public Incident createIncident(@RequestBody Incident incident) {
        return incidentRepository.save(incident);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Incident> getIncidentById(@PathVariable Long id) {
        return incidentRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}/status")
    public ResponseEntity<Incident> updateStatus(@PathVariable Long id, @RequestBody String status) {
        return incidentRepository.findById(id)
                .map(incident -> {
                    incident.setStatus(status);
                    return ResponseEntity.ok(incidentRepository.save(incident));
                })
                .orElse(ResponseEntity.notFound().build());
    }
}
