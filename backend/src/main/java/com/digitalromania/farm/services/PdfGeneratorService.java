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

    public String generateApiaGrantRequest(String farmerName, String iban, String animalTag) {
        String fileName = "APIA_Grant_" + animalTag + "_" + System.currentTimeMillis() + ".pdf";
        String filePath = STORAGE_DIR + fileName;

        try (PDDocument document = new PDDocument()) {
            PDPage page = new PDPage();
            document.addPage(page);

            try (PDPageContentStream contentStream = new PDPageContentStream(document, page)) {
                contentStream.beginText();
                contentStream.setFont(new PDType1Font(Standard14Fonts.FontName.HELVETICA_BOLD), 18);
                contentStream.newLineAtOffset(50, 700);
                contentStream.showText("CERERE UNICA DE PLATA - APIA");
                contentStream.endText();
                
                contentStream.beginText();
                contentStream.setFont(new PDType1Font(Standard14Fonts.FontName.HELVETICA), 12);
                contentStream.newLineAtOffset(50, 650);
                contentStream.setLeading(14.5f);
                
                contentStream.showText("Subsemnatul/a " + farmerName + ", formulez prezenta cerere de");
                contentStream.newLine();
                contentStream.showText("Sprijin Cuplat Zootehnic (SCZ) pentru animalul cu crotalia:");
                contentStream.newLine();
                contentStream.showText(animalTag);
                contentStream.newLine();
                contentStream.newLine();
                contentStream.showText("Va rog sa virati subventia in contul IBAN:");
                contentStream.newLine();
                contentStream.showText(iban);
                contentStream.newLine();
                contentStream.newLine();
                contentStream.showText("Semnat digital de: " + farmerName);
                
                contentStream.endText();
            }
            document.save(filePath);
            return filePath;
        } catch (IOException e) {
            throw new RuntimeException("Error generating APIA PDF", e);
        }
    }

    public String generateF1Form(String vetName, String animalTag) {
        String fileName = "F1_Form_" + animalTag + "_" + System.currentTimeMillis() + ".pdf";
        String filePath = STORAGE_DIR + fileName;

        try (PDDocument document = new PDDocument()) {
            PDPage page = new PDPage();
            document.addPage(page);

            try (PDPageContentStream contentStream = new PDPageContentStream(document, page)) {
                contentStream.beginText();
                contentStream.setFont(new PDType1Font(Standard14Fonts.FontName.HELVETICA_BOLD), 18);
                contentStream.newLineAtOffset(50, 700);
                contentStream.showText("FORMULAR DE IDENTIFICARE (F1) - ANSVSA");
                contentStream.endText();
                
                contentStream.beginText();
                contentStream.setFont(new PDType1Font(Standard14Fonts.FontName.HELVETICA), 12);
                contentStream.newLineAtOffset(50, 650);
                contentStream.setLeading(14.5f);
                
                contentStream.showText("Animalul a fost examinat si i-a fost atasata crotalia:");
                contentStream.newLine();
                contentStream.setFont(new PDType1Font(Standard14Fonts.FontName.HELVETICA_BOLD), 14);
                contentStream.showText(animalTag);
                contentStream.setFont(new PDType1Font(Standard14Fonts.FontName.HELVETICA), 12);
                contentStream.newLine();
                contentStream.newLine();
                contentStream.showText("Stare de sanatate: Clinic Sanatos");
                contentStream.newLine();
                contentStream.showText("Aprobat de Medic Veterinar: " + vetName);
                
                contentStream.endText();
            }
            document.save(filePath);
            return filePath;
        } catch (IOException e) {
            throw new RuntimeException("Error generating F1 PDF", e);
        }
    }
}
