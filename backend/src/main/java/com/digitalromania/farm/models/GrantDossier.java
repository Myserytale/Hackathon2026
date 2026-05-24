package com.digitalromania.farm.models;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "grant_dossiers")
public class GrantDossier {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "farmer_id", nullable = false)
    private User farmer;

    @ManyToOne
    @JoinColumn(name = "veterinarian_id")
    private User veterinarian;

    @ManyToOne
    @JoinColumn(name = "animal_id", nullable = false)
    private Animal animal;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private GrantDossierStatus status = GrantDossierStatus.DRAFT_FERMIER;

    // The document generated and signed by the Farmer (APIA Grant Request)
    @Column(name = "farmer_document_url")
    private String farmerDocumentUrl;

    // The document generated and signed by the Vet (F1 Form)
    @Column(name = "vet_document_url")
    private String vetDocumentUrl;

    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();

    @Column(name = "updated_at")
    private LocalDateTime updatedAt = LocalDateTime.now();

    @Column(name = "farm_name")
    private String farmName;

    @Column(name = "animal_tag")
    private String animalTag;

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public User getFarmer() { return farmer; }
    public void setFarmer(User farmer) { this.farmer = farmer; }

    public User getVeterinarian() { return veterinarian; }
    public void setVeterinarian(User veterinarian) { this.veterinarian = veterinarian; }

    public Animal getAnimal() { return animal; }
    public void setAnimal(Animal animal) { this.animal = animal; }

    public GrantDossierStatus getStatus() { return status; }
    public void setStatus(GrantDossierStatus status) { this.status = status; }

    public String getFarmerDocumentUrl() { return farmerDocumentUrl; }
    public void setFarmerDocumentUrl(String farmerDocumentUrl) { this.farmerDocumentUrl = farmerDocumentUrl; }

    public String getVetDocumentUrl() { return vetDocumentUrl; }
    public void setVetDocumentUrl(String vetDocumentUrl) { this.vetDocumentUrl = vetDocumentUrl; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public String getFarmName() { return farmName; }
    public void setFarmName(String farmName) { this.farmName = farmName; }

    public String getAnimalTag() { return animalTag; }
    public void setAnimalTag(String animalTag) { this.animalTag = animalTag; }
}
