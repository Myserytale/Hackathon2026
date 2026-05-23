package com.digitalromania.farm.repositories;

import com.digitalromania.farm.models.GrantDossier;
import com.digitalromania.farm.models.GrantDossierStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface GrantDossierRepository extends JpaRepository<GrantDossier, Long> {
    List<GrantDossier> findByFarmerId(Long farmerId);
    List<GrantDossier> findByVeterinarianId(Long veterinarianId);
    List<GrantDossier> findByStatus(GrantDossierStatus status);
}
