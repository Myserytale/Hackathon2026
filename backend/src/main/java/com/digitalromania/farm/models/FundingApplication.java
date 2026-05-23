package com.digitalromania.farm.models;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import org.hibernate.annotations.SQLDelete;
import org.hibernate.annotations.SQLRestriction;
import com.digitalromania.farm.config.AuditListener;
import java.time.LocalDate;
import java.io.Serializable;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@SQLDelete(sql = "UPDATE funding_application SET deleted = true WHERE id=?")
@SQLRestriction("deleted=false")
@EntityListeners(AuditListener.class)
public class FundingApplication implements Serializable {
    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long farmerId;

    @Column(nullable = false)
    private String status; // Pending, Approved, Rejected

    private Double amount;
    private String purpose;
    private LocalDate submissionDate;

    private Boolean deleted = false;
}
