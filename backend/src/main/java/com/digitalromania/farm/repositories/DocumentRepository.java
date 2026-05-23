package com.digitalromania.farm.repositories;

import com.digitalromania.farm.models.Document;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface DocumentRepository extends JpaRepository<Document, Long> {
    List<Document> findByAnimalId(Long animalId);
}
