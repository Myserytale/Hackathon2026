package com.digitalromania.farm.models;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import org.hibernate.annotations.SQLDelete;
import org.hibernate.annotations.SQLRestriction;
import com.digitalromania.farm.config.AuditListener;
import java.time.LocalDateTime;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@SQLDelete(sql = "UPDATE incident SET deleted = true WHERE id=?")
@SQLRestriction("deleted=false")
@EntityListeners(AuditListener.class)
public class Incident {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String type; // Disease, Missing Animal, Damage

    private String description;
    private String location;
    
    private Long animalId; // Optional, if the incident is tied to a specific animal

    private LocalDateTime reportedAt;
    
    @Column(nullable = false)
    private String status; // Open, Investigating, Resolved

    private boolean deleted = false;
}
