library(shiny) 
library(data.table) 

dictlist <- readRDS("dictlist.rds") 
source("pkn.findnextword.R") 
 

shinyServer( 
     function(input, output) { 
     ## Various output variables 
#         output$osentenceInputVar <- renderText({ 
#             input$submitButton 
#             sentence <- isolate(paste(input$sentenceInputVar)) 
#             }) 
 

## Near the VERIFY button: text that tells you that you are unverified, or that you need to double-check your credentials 
     output$oWordPredictions <- renderText({ 
         input$submitButton 
#             if (nchar(input$sentenceInputVar) == 0) 
#                 paste("Please type a sentence, then press 'Submit'") 
#             else if (nchar(input$sentenceInputVar) > 0 & 
#               nchar(gsub(pattern = '[ !"#$%&???\\(\\)]', replacement = "", input$sentenceInputVr)) == 0) 
#                 paste("Please type more than just spaces", input$sentenceInputVar) 
#             else 
         results <- isolate(paste( 
             unlist(lapply(pkn.findNextWord(string = input$sentenceInputVar,  
                                                  dictlist = dictlist,  
                                                  ncandidates = 50,  
                                                  min_cand_freq = 2)$Candidate[1:5], 
                                                         function(x) paste0("[", x, "]") 
                                                          ) 
                                                   ) 
            )) 
     }) 
})