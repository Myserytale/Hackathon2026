package com.digitalromania.farm.repositories;

import com.digitalromania.farm.models.FundingApplication;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface FundingApplicationRepository extends JpaRepository<FundingApplication, Long> {
    List<FundingApplication> findByFarmerId(Long farmerId);
    List<FundingApplication> findByStatus(String status);
}
