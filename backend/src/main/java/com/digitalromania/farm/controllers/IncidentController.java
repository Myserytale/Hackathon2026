package com.digitalromania.farm.controllers;

import com.digitalromania.farm.models.Incident;
import com.digitalromania.farm.repositories.IncidentRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

@RestController
@RequestMapping("/api/incidents")
public class IncidentController {

    @Autowired
    private IncidentRepository incidentRepository;

    private final CopyOnWriteArrayList<SseEmitter> emitters = new CopyOnWriteArrayList<>();

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
        Incident saved = incidentRepository.save(incident);
        
        // Broadcast to all connected clients
        for (SseEmitter emitter : emitters) {
            try {
                emitter.send(SseEmitter.event().name("incident").data(saved));
            } catch (IOException e) {
                emitters.remove(emitter);
            }
        }
        
        return saved;
    }

    @GetMapping("/notifications")
    public SseEmitter subscribeToIncidents() {
        SseEmitter emitter = new SseEmitter(3600000L); // 1 hour timeout
        emitters.add(emitter);
        
        emitter.onCompletion(() -> emitters.remove(emitter));
        emitter.onTimeout(() -> emitters.remove(emitter));
        emitter.onError((e) -> emitters.remove(emitter));
        
        return emitter;
    }

    @GetMapping("/{id}")
    public ResponseEntity<Incident> getIncidentById(@PathVariable Long id) {
        return incidentRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping(value = "/{id}/status", consumes = {"application/json", "text/plain"})
    public ResponseEntity<Incident> updateStatus(@PathVariable Long id, @RequestBody String status) {
        // Strip quotes in case it was sent as a JSON string like "\"RESOLVED\""
        String cleanStatus = status.trim().replaceAll("\"", "");
        return incidentRepository.findById(id)
                .map(incident -> {
                    incident.setStatus(cleanStatus);
                    return ResponseEntity.ok(incidentRepository.save(incident));
                })
                .orElse(ResponseEntity.notFound().build());
    }
}
