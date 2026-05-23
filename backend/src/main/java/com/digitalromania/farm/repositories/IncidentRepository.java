package com.digitalromania.farm.repositories;

import com.digitalromania.farm.models.Incident;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface IncidentRepository extends JpaRepository<Incident, Long> {
    List<Incident> findByAnimalId(Long animalId);
    List<Incident> findByStatus(String status);
}
