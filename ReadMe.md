This app by Samuel P. Folledo will essentially do the following:
1) Listen for speech (recording functionalities in the future) and grabs the most complicated word in a sentence.
2) Display the top 3 most complicated word and give it an image and definition or explanation

This app's User Interfaces will be programmed in Swift and apply Data Science's TF-IDF algorithm in order to present the most complicated word.
    - From here, we can go back to Swift and present our Google/Wikipedia search results for the returned "complicated word"
    
    
    
Important things to know to program this:
- log or log<sub>b</sub>n = p //log base b of some number n = p
    - base raised to what power equals the number
    
- tf-idf score of a word, w is:
    - tf(w) * idf(w) = points of how complicated a word is
        - tf(w) = (number of times the word appears in a document) / (total number of words in a document)
        - idf(w) = log(number of documents / number of documents that contain the word w)



Important links
- Text-to-speech youtube link:
    - https://www.youtube.com/watch?v=EhI4j5drcFI
- Using TF-IDF to convert unstructured text to useful features
    - https://www.youtube.com/watch?v=hXNbFNCgPfY
