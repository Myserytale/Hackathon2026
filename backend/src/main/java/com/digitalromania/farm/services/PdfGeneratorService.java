package com.digitalromania.farm.services;

import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.pdmodel.PDPageContentStream;
import org.apache.pdfbox.pdmodel.font.PDType1Font;
import org.apache.pdfbox.pdmodel.font.Standard14Fonts;
import org.springframework.stereotype.Service;

import java.io.File;
import java.io.IOException;

@Service
public class PdfGeneratorService {

    private static final String STORAGE_DIR = "generated_docs/";

    public PdfGeneratorService() {
        File directory = new File(STORAGE_DIR);
        if (!directory.exists()) {
            directory.mkdirs();
        }
    }

    public String generateApiaGrantRequest(String farmName, String iban, String animalTag, String signatureBase64) {
        String fileName = "APIA_Grant_" + animalTag + "_" + System.currentTimeMillis() + ".pdf";
        String filePath = STORAGE_DIR + fileName;

        try (PDDocument document = new PDDocument()) {
            PDPage page = new PDPage();
            document.addPage(page);

            try (PDPageContentStream contentStream = new PDPageContentStream(document, page)) {
                // Border
                contentStream.setLineWidth(2f);
                contentStream.addRect(20, 20, page.getMediaBox().getWidth() - 40, page.getMediaBox().getHeight() - 40);
                contentStream.stroke();
                
                contentStream.beginText();
                contentStream.setFont(new PDType1Font(Standard14Fonts.FontName.HELVETICA_BOLD), 14);
                contentStream.newLineAtOffset(50, 730);
                contentStream.showText("GUVERNUL ROMANIEI");
                contentStream.newLineAtOffset(0, -15);
                contentStream.showText("MINISTERUL AGRICULTURII SI DEZVOLTARII RURALE");
                contentStream.newLineAtOffset(0, -15);
                contentStream.showText("AGENTIA DE PLATI SI INTERVENTIE PENTRU AGRICULTURA (APIA)");
                contentStream.endText();
                
                contentStream.setLineWidth(1f);
                contentStream.moveTo(50, 690);
                contentStream.lineTo(page.getMediaBox().getWidth() - 50, 690);
                contentStream.stroke();

                contentStream.beginText();
                contentStream.setFont(new PDType1Font(Standard14Fonts.FontName.HELVETICA_BOLD), 18);
                contentStream.newLineAtOffset(150, 650);
                contentStream.showText("CERERE UNICA DE PLATA");
                contentStream.newLineAtOffset(25, -20);
                contentStream.setFont(new PDType1Font(Standard14Fonts.FontName.HELVETICA_BOLD), 12);
                contentStream.showText("Sprijin Cuplat Zootehnic (SCZ)");
                contentStream.endText();
                
                contentStream.beginText();
                contentStream.setFont(new PDType1Font(Standard14Fonts.FontName.HELVETICA), 12);
                contentStream.newLineAtOffset(50, 580);
                contentStream.setLeading(20f);
                
                contentStream.showText("Catre Directorul Centrului Judetean APIA,");
                contentStream.newLine();
                contentStream.newLine();
                contentStream.showText("Subsemnatul/Reprezentantul legal al exploatatiei: ");
                contentStream.setFont(new PDType1Font(Standard14Fonts.FontName.HELVETICA_BOLD), 12);
                contentStream.showText(farmName != null && !farmName.isEmpty() ? farmName : "__________________");
                contentStream.setFont(new PDType1Font(Standard14Fonts.FontName.HELVETICA), 12);
                contentStream.newLine();
                
                contentStream.showText("Inregistrata la ONRC / ANSVSA, solicit prin prezenta acordarea grantului european ");
                contentStream.newLine();
                contentStream.showText("in valoare de 400 EUR pentru nasterea in bune conditii a vitelului identificat ");
                contentStream.newLine();
                contentStream.showText("in Sistemul National (SNIIA) cu crotalia:");
                contentStream.newLine();
                contentStream.newLine();
                
                contentStream.setFont(new PDType1Font(Standard14Fonts.FontName.HELVETICA_BOLD), 16);
                contentStream.showText("CROTALIA: " + (animalTag != null && !animalTag.isEmpty() ? animalTag : "__________________"));
                contentStream.setFont(new PDType1Font(Standard14Fonts.FontName.HELVETICA), 12);
                contentStream.newLine();
                contentStream.newLine();
                
                contentStream.showText("Declar pe propria raspundere ca animalul este in viata, sanatos, si ");
                contentStream.newLine();
                contentStream.showText("solicit ca plata subventiei sa se faca in contul bancar:");
                contentStream.newLine();
                
                contentStream.setFont(new PDType1Font(Standard14Fonts.FontName.HELVETICA_BOLD), 14);
                contentStream.showText("IBAN: " + (iban != null && !iban.isEmpty() ? iban : "__________________"));
                contentStream.setFont(new PDType1Font(Standard14Fonts.FontName.HELVETICA), 12);
                contentStream.newLine();
                contentStream.newLine();
                contentStream.newLine();
                
                contentStream.showText("Data depunerii: " + java.time.LocalDate.now().toString());
                contentStream.newLine();
                contentStream.newLine();
                
                contentStream.showText("Semnatura Fermier/Reprezentant Legal:");
                contentStream.newLine();
                if (signatureBase64 == null || signatureBase64.isEmpty()) {
                    contentStream.showText("_________________________________");
                    contentStream.newLine();
                    contentStream.newLine();
                } else {
                    // Make room for the image
                    contentStream.newLine();
                    contentStream.newLine();
                    contentStream.newLine();
                    contentStream.newLine();
                    contentStream.newLine();
                }
                
                contentStream.setFont(new PDType1Font(Standard14Fonts.FontName.HELVETICA_OBLIQUE), 14);
                contentStream.showText("Document generat si validat digital in platforma Digital Romania Farm.");
                
                contentStream.endText();
                
                // Draw signature image if provided
                if (signatureBase64 != null && !signatureBase64.isEmpty()) {
                    try {
                        byte[] imageBytes = java.util.Base64.getDecoder().decode(signatureBase64);
                        org.apache.pdfbox.pdmodel.graphics.image.PDImageXObject pdImage = 
                            org.apache.pdfbox.pdmodel.graphics.image.PDImageXObject.createFromByteArray(document, imageBytes, "signature");
                        
                        float imgWidth = pdImage.getWidth();
                        float imgHeight = pdImage.getHeight();
                        float targetWidth = 150f;
                        float targetHeight = (imgHeight / imgWidth) * targetWidth;
                        
                        // Prevent the signature from being too tall if it's drawn vertically
                        if (targetHeight > 80f) {
                            targetHeight = 80f;
                            targetWidth = (imgWidth / imgHeight) * targetHeight;
                        }
                        
                        // Position image near the signature text. 50 is left margin.
                        contentStream.drawImage(pdImage, 50, 180, targetWidth, targetHeight);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            }
            document.save(filePath);
            return filePath;
        } catch (IOException e) {
            throw new RuntimeException("Error generating APIA PDF", e);
        }
    }

    public String generateF1Form(String vetName, String animalTag, String signatureBase64) {
        String fileName = "F1_Form_" + animalTag + "_" + System.currentTimeMillis() + ".pdf";
        String filePath = STORAGE_DIR + fileName;

        try (PDDocument document = new PDDocument()) {
            PDPage page = new PDPage();
            document.addPage(page);

            try (PDPageContentStream contentStream = new PDPageContentStream(document, page)) {
                // Border
                contentStream.setLineWidth(2f);
                contentStream.addRect(20, 20, page.getMediaBox().getWidth() - 40, page.getMediaBox().getHeight() - 40);
                contentStream.stroke();
                
                contentStream.beginText();
                contentStream.setFont(new PDType1Font(Standard14Fonts.FontName.HELVETICA_BOLD), 14);
                contentStream.newLineAtOffset(50, 730);
                contentStream.showText("AUTORITATEA NATIONALA SANITARA VETERINARA");
                contentStream.newLineAtOffset(0, -15);
                contentStream.showText("SI PENTRU SIGURANTA ALIMENTELOR (ANSVSA)");
                contentStream.endText();
                
                contentStream.setLineWidth(1f);
                contentStream.moveTo(50, 700);
                contentStream.lineTo(page.getMediaBox().getWidth() - 50, 700);
                contentStream.stroke();

                contentStream.beginText();
                contentStream.setFont(new PDType1Font(Standard14Fonts.FontName.HELVETICA_BOLD), 18);
                contentStream.newLineAtOffset(150, 660);
                contentStream.showText("FORMULAR DE IDENTIFICARE (F1)");
                contentStream.endText();
                
                contentStream.beginText();
                contentStream.setFont(new PDType1Font(Standard14Fonts.FontName.HELVETICA), 12);
                contentStream.newLineAtOffset(50, 600);
                contentStream.setLeading(20f);
                
                contentStream.showText("Subsemnatul, medic veterinar de libera practica imputernicit, ");
                contentStream.newLine();
                contentStream.setFont(new PDType1Font(Standard14Fonts.FontName.HELVETICA_BOLD), 14);
                contentStream.showText("Dr. " + vetName);
                contentStream.setFont(new PDType1Font(Standard14Fonts.FontName.HELVETICA), 12);
                contentStream.newLine();
                contentStream.newLine();
                
                contentStream.showText("Atest prin prezenta ca animalul a fost examinat clinic la data curenta ");
                contentStream.newLine();
                contentStream.showText("si a fost identificat prin aplicarea crotaliei oficiale:");
                contentStream.newLine();
                contentStream.newLine();
                
                contentStream.setFont(new PDType1Font(Standard14Fonts.FontName.HELVETICA_BOLD), 16);
                contentStream.showText("CROTALIA: " + animalTag);
                contentStream.setFont(new PDType1Font(Standard14Fonts.FontName.HELVETICA), 12);
                contentStream.newLine();
                contentStream.newLine();
                
                contentStream.showText("Stare de sanatate constatata:");
                contentStream.newLine();
                contentStream.setFont(new PDType1Font(Standard14Fonts.FontName.HELVETICA_BOLD), 14);
                contentStream.showText("CLINIC SANATOS - APT PENTRU ACORDARE GRANT SCZ");
                contentStream.setFont(new PDType1Font(Standard14Fonts.FontName.HELVETICA), 12);
                contentStream.newLine();
                contentStream.newLine();
                contentStream.newLine();
                
                contentStream.showText("Data eliberarii: " + java.time.LocalDate.now().toString());
                contentStream.newLine();
                contentStream.newLine();
                
                contentStream.showText("Parafa si Semnatura Medic Veterinar:");
                contentStream.newLine();
                if (signatureBase64 == null || signatureBase64.isEmpty()) {
                    contentStream.showText("_________________________________");
                    contentStream.newLine();
                    contentStream.newLine();
                } else {
                    contentStream.newLine();
                    contentStream.newLine();
                    contentStream.newLine();
                    contentStream.newLine();
                    contentStream.newLine();
                }
                
                contentStream.setFont(new PDType1Font(Standard14Fonts.FontName.HELVETICA_OBLIQUE), 14);
                contentStream.showText("Document vizat digital in platforma Digital Romania Farm.");
                contentStream.endText();
                
                // Draw signature image if provided
                if (signatureBase64 != null && !signatureBase64.isEmpty()) {
                    try {
                        byte[] imageBytes = java.util.Base64.getDecoder().decode(signatureBase64);
                        org.apache.pdfbox.pdmodel.graphics.image.PDImageXObject pdImage = 
                            org.apache.pdfbox.pdmodel.graphics.image.PDImageXObject.createFromByteArray(document, imageBytes, "signature");
                        
                        float imgWidth = pdImage.getWidth();
                        float imgHeight = pdImage.getHeight();
                        float targetWidth = 150f;
                        float targetHeight = (imgHeight / imgWidth) * targetWidth;
                        
                        if (targetHeight > 80f) {
                            targetHeight = 80f;
                            targetWidth = (imgWidth / imgHeight) * targetHeight;
                        }
                        
                        contentStream.drawImage(pdImage, 50, 200, targetWidth, targetHeight);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            }
            document.save(filePath);
            return filePath;
        } catch (IOException e) {
            throw new RuntimeException("Error generating F1 PDF", e);
        }
    }
}
