REPORT ON NEXT WORD PREDICTION-APP
========================================================
author: Urli2016
date: July, 10th 2016
height: 1440
width: 1200
transition: concave
font-family: 'Helvetica'


INTRODUCTION
========================================================
The purpose was to create a next word prediction - app that predicts the word which is most likely to follow to a word or sentence input. For example, given "I want to" as the input sentence, the app should suggest words like "eat", "learn", or "go". This report is divided into two major steps:

A. Training the app on a large corpus of text (importing the corpus plus cleaning the corpus
   from undesired items/words, converting the corpus into data tables for n-gram models).
B. Generating the predictions (smoothing the algorithm for n-gram model, retrieving
   predictions).

There were three corpora of text available in English: text from social media giant Twitter: from tweets, from blogs, and from news articles online. I worked on all datasets, even though all of the code in my app and in my report uses the "News" data set.  All datasets can be obtained at:

    https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip


###### HOW TO USE THE APP
1. Load the app at

    https://urli2016.shinyapps.io/Next_Word_Prediction/

2. Give the app approximately 10 to 15 seconds to load.
3. Type a sentence or a word into the textbox (examples: "She wants to go" or
4. "It used to", "I have been in the", type whatever is on your mind)
5. Hit the submit button
6. 5 word predictions will be shown at the bottom of the textbox.

NATURAL LANGUAGE PROCESSING (NLP) AND N-GRAM-MODELS
========================================================
<small>Natural language processing (NLP) is a field of computer science, artificial intelligence, and computational linguistics concerned with the interactions between computers and human (natural) languages. In NLP text documents are divided into so-called tokens (in this case: individual words), which can be grouped into so-called n-grams. In the fields of computational linguistics and probability, an n-gram is a contiguous sequence of n items from a given sequence of text or speech. The n-grams typically are collected from a text or speech corpus. An n-gram of size 1 (1 word) is referred to as a "unigram"; size 2 is a "bigram" (word pair); size 3 is a "trigram" (3 words). Please find more information here:</small>

    https://en.wikipedia.org/wiki/Natural_language_processing
    https://en.wikipedia.org/wiki/Language_model

<small>After studying several word-prediction models such as the Katz-backoff model which is a generative n-gram language model that estimates the conditional probability of a word given its history in the n-gram. It accomplishes this estimation by "backing-off" to models with smaller histories under certain conditions. By doing so, the model with the most reliable information about a given history is used to provide the better results. Please find more information here:</small>

    https://en.wikipedia.org/wiki/Katz%27s_back-off_model

<small>I have chosen the Kneser-Ney-Model, because it is very simple and easy to use. The computational speed is much better than in the previous mentioned Katz-Backoff-model plus it is based on data tables and their counts. Kneser-Ney smoothing is a method primarily used to calculate the probability distribution of n-grams in a document based on their histories. It is widely considered the most effective method of smoothing due to its use of absolute discounting by subtracting a fixed value from the probability's lower order terms to omit n-grams with lower frequencies. A common example that illustrates the concept behind this method is the frequency of the bigram "San Francisco". If it appears several times in a training corpus, the frequency of the unigram "Francisco" will also be high. Relying on only the unigram frequency to predict the frequencies of n-grams leads to skewed results; Kneser-Ney smoothing corrects this by considering the frequency of the unigram in relation to possible words preceding it. More information about Kneser-Ney:</small> 

    https://en.wikipedia.org/wiki/Kneser%E2%80%93Ney_smoothing


TOKENIZING TEXT & N-GRAMS
========================================================

I tokenized the text of the dataset using tau and then I created data tables for each ngram model and I have built this candidate list based on bigrams:


```r
source("pkn.candidateList.R")
candidateList <- function(string, dictlist, min = 2) { 
     #Inputs: 
     # string: a vector of split words 
     # dictlist: a list of ngram models 
     # min: only bigrams with a minimum frequency of "min" will be returned 
     #Output: 
     # result: a vector of split words that are candidate "next words" to a string, based on bigrams 
     if(length(grep(" ", string)) > 0){ 
         string <- strsplit(string, split = " ")[[1]] 
     } 
     result <- dictlist[[2]][token1 == tail(string, 1) & count >= min][order(-count)][1:100]$token2 
     result <- result[result!= "s" & result!= "rt" & result!= "th" & result != "st"] 
     return(result) 
}
```


EXPLANATION OF MY PKN.CALC function
========================================================
STEPS
1. Calculating the Kneser-Ney probability (PKN) of the lowest order (unigram level).
2. Calculating the PKN of all the lower orders using successively lower PKN values.
3. Calculating the highest PKN value using the PKN of the lower values, and return this value.


```r
source("pkn.calc.R")
pkn.calc <- function(string, candidate, dictlist){ 
     #Input:  
     # string: a full string of words, without a candidate at the end 
     # candidate: a candidate word for which to calculate pkn(candidate|string) 
     # dictlist: a list of ngram models as dictionaries 
     #Output: 
     # print substring used for the search 
     # pkn value for pkn(candidate|string) 
      
     ##Init 
     #Create a logical vector to subset ngram model dataframe: 
     source("pkn.logical.dfchecker.R") 
     #Continuation count: 
     source("pkn.continuationCount.R") 
      
         #Append the candidate to the string 
         append.candidate <- function(string, candidate){ 
             #string: a vector of words in a string 
             #candidate: a word to be added to end of string 
             cand.result <- paste(string, candidate, collapse = " ") 
             return(cand.result) 
         } 
          
         #Appending a candidate string EXAMPLE: "but he is the" + "one" 
         string <- append.candidate(string, candidate) 
          
         #reduceString: split the string into words, and reduce length depending on dictlist length 
         source("pkn.reduceString.R") 
         string <- reduceString(string, dictlist) 
          
     #     print(paste("Calculating pkn for reduced string: [", paste(string, collapse = " "), "]")) 
          
         #Highest order calculation PKN 
         source("pkn.highest.R") 
          
         discount <- 0.75 
         n <- length(string) 
     
    #     Lowest order calculation #### 
    #     PKN = continuationCount(any.wi.to.n) / continuationCount(any.wi.to.n.minus.1.any) 
         pkn.lowest <- nrow(dictlist[[2]][token2 == tail(string,1),]) /  
             nrow(dictlist[[2]]) #the best, the same, the world     
     
         #List of results for lower order pkn calculations   
         pkn.lower.list <- list("lowest" = pkn.lowest)    
     
         #Lower order calculation 
         for(i in (n-2):2){ #i is the recursion counter, from i until n-1  
             string_start = i 
             if(i == 0) break 
          
     #         print("Lower order calculation -----------") 
     #         print(paste("-- i <-", i, "---------")) 
              
             #Continuation count of [any][wi to n] in dictlist[[n]] 
             cont.ANY.wi.to.n <- continuationCount(string_start, 
                                                   token_start   = 2,  
                                                   ntokens       = n-i+1,  
                                                   string,  
                                                   dict_number   = n-i+2,  
                                                   dictlist) 
             if(length(cont.ANY.wi.to.n) == 0){cont.ANY.wi.to.n = discount + 0.01} 
     #         if(length(cont.ANY.wi.to.n) == 0){cont.ANY.wi.to.n = 0.1} 
              
             #Continuation count of [any][wi to n-1][any] in dictlist[[n]] 
             cont.ANY.wi.to.n.minus.1.ANY <- continuationCount(string_start,  
                                                               token_start   = 2,  
                                                               ntokens       = n-i,  
                                                               string,  
                                                               dict_number   = n-i+2,  
                                                               dictlist) 
             if(length(cont.ANY.wi.to.n.minus.1.ANY) == 0 | is.nan(cont.ANY.wi.to.n.minus.1.ANY)){cont.ANY.wi.to.n.minus.1.ANY = 0.75} 
              
             #Continuation count of [wi to n-1][any] in dictlist[[n-1]] 
             cont.wi.to.n.minus.1.ANY <- continuationCount(string_start,  
                                                           token_start   = 1,  
                                                           ntokens       = n-i,  
                                                           string,  
                                                           dict_number   = n-i+1,  
                                                           dictlist) 
             if(length(cont.wi.to.n.minus.1.ANY) == 0){cont.wi.to.n.minus.1.ANY = 0.1} 
     #         if(length(cont.wi.to.n.minus.1.ANY) == 0){cont.wi.to.n.minus.1.ANY = 0.1} 
              
             #<<print debugging 
             #end print debugging>> 
              
             #Set to temporary result 
             lowerorder <- tail(pkn.lower.list,1)[[1]] 
             pkn.result.temp <- max(cont.ANY.wi.to.n - discount,0)/cont.ANY.wi.to.n.minus.1.ANY +  
             discount * lowerorder * cont.wi.to.n.minus.1.ANY/cont.ANY.wi.to.n.minus.1.ANY 
     
        
             pkn.lower.list <- c(pkn.lower.list, lower.pkn = pkn.result.temp) 
         } 
         lowerorder <- tail(pkn.lower.list,1)[[1]] 
          
         pkn.result <- FALSE 
         counter <- 1 
         while(pkn.result == FALSE & length(string) > 2){ 
             pkn.result <- pkn.highest(string, lowerorder, discount, dictlist) 
             #if still is FALSE, then reduce string by one word, and revert lowerorder value to a lower pkn value: 
             if(pkn.result == FALSE & length(string) > 2){ 
                 counter <- counter + 1 
                 string <- string[-1] 
                 n <- length(string) 
                 print("Warning: String reduced to:") 
                 print(string) 
                 lowerorder <- tail(pkn.lower.list,counter)[[1]] 
             }  
         } 
         if(pkn.result == FALSE & length(string) == 2){ 
             print("Warning: Reverted to pkn.lowest:") 
             return(pkn.lowest) 
         } 
         return(pkn.result) 
     }
```


CONCLUSION AND SUMMARY
========================================================

Kneser-Ney smoothing algorithm works well, if implemented correctly.

ADVANTAGES:
- it is based on data tables and their counts,
- Kneser-Ney smoothing is a method primarily used to calculate the probability,
  distribution of n-grams in a document based on their histories,
- better computational speed,
- much of this algorithm can be done in parallel across several nodes.


My next word prediction-app is easy to use and self-explaining.

Please find my Next Word Prediction-app here:

    https://urli2016.shinyapps.io/Next_Word_Prediction/


All the related code for this app can be found on github:

    https://github.com/Urli2016/Next_Word_Prediction

For more information about the app and Kneser-Ney smoothing algorithm please feel free to contact me: Despoinaellina [at] gmail [dot] com
