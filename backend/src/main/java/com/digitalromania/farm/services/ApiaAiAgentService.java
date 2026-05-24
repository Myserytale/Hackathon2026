package com.digitalromania.farm.services;

import com.digitalromania.farm.models.GrantDossier;
import com.digitalromania.farm.models.GrantDossierStatus;
import com.digitalromania.farm.models.User;
import com.digitalromania.farm.repositories.GrantDossierRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;

import java.util.List;
import java.util.logging.Logger;

@Service
public class ApiaAiAgentService {

    private static final Logger logger = Logger.getLogger(ApiaAiAgentService.class.getName());

    @Autowired
    private GrantDossierRepository grantDossierRepository;

    @Autowired
    private EmailService emailService;

    /**
     * This scheduled task runs every 30 seconds.
     * It looks for dossiers that are PENDING_APIA and simulates an AI evaluation.
     */
    @Scheduled(fixedDelay = 30000)
    @Transactional
    public void evaluatePendingDossiers() {
        List<GrantDossier> pendingDossiers = grantDossierRepository.findByStatus(GrantDossierStatus.PENDING_APIA);

        if (pendingDossiers.isEmpty()) {
            return;
        }

        logger.info("🤖 APIA AI Agent woke up. Found " + pendingDossiers.size() + " dossiers to evaluate.");

        for (GrantDossier dossier : pendingDossiers) {
            evaluateDossier(dossier);
        }
    }

    private void evaluateDossier(GrantDossier dossier) {
        logger.info("🤖 AI Agent is analyzing Dossier #" + dossier.getId() + "...");
        
        // SKELETON: Here is where we would call an LLM (OpenAI, Gemini)
        // We would send the text extracted from dossier.getFarmerDocumentUrl() and dossier.getVetDocumentUrl()
        // Example logic:
        // String farmerText = pdfService.extractText(dossier.getFarmerDocumentUrl());
        // String vetText = pdfService.extractText(dossier.getVetDocumentUrl());
        // String aiResponse = llmClient.analyze(farmerText, vetText);

        try {
            // Simulating AI processing time
            Thread.sleep(2000);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }

        // For the Hackathon, we will auto-approve it after "analysis"
        logger.info("🤖 AI Agent decision: APPROVED for Dossier #" + dossier.getId());
        
        dossier.setStatus(GrantDossierStatus.APPROVED);
        dossier.setUpdatedAt(LocalDateTime.now());
        grantDossierRepository.save(dossier);

        // Send confirmation email to the farmer
        User farmer = dossier.getFarmer();
        if (farmer != null && farmer.getEmail() != null) {
            String farmerName = farmer.getName() != null ? farmer.getName() : farmer.getUsername();
            // In a real AI implementation, we'd include the AI's explanation/notes here.
            emailService.sendDossierStatusEmail(
                farmer.getEmail(), 
                farmerName, 
                "APPROVED (Evaluat de APIA AI Agent)", 
                dossier.getFarmerDocumentUrl() // Sending back the farmer's document
            );
        }
    }
}
