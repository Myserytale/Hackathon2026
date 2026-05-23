package com.digitalromania.farm.repositories;

import com.digitalromania.farm.models.VeterinaryConsultation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface VeterinaryConsultationRepository extends JpaRepository<VeterinaryConsultation, Long> {
    List<VeterinaryConsultation> findByAnimalId(Long animalId);
    List<VeterinaryConsultation> findByVetId(Long vetId);
}
