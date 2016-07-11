library(shiny)

shinyUI(fluidPage( 
 titlePanel("Next Word Prediction"), 
     fluidRow("Note: Please calculate up to 15 secs for the app to load."), 
     hr(), 
     fluidRow("In the space below:"), 
     fluidRow("1. Type a sentence"), 
     fluidRow("2. Press Submit"),  
     fluidRow("Wait a few seconds... and then you will see a few words that are likely to follow up next"), 
     hr(), 
     textInput('sentenceInputVar', 'Type here:'), 
     actionButton('submitButton', 'Submit'), 
     fluidRow('(Example: "She wants to go" or "It used to")'), 
     verbatimTextOutput("oWordPredictions"), 
      
     hr(), 
      
     fluidRow("This app uses a simplified and very basic version of the Kneser-Ney smoothing algorithm."), 
     fluidRow("Special thanks to my instructors from John Hopkins University: Brian Caffo, Jeff Leaks and Roger Peng"), 
     hr(), 
     fluidRow("This app was created by Urli2016 Despoinaellina [at] gmail [dot] com") 
 ) 
)