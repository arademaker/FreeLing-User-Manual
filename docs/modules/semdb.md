
# Semantic Database Module {#semantic-database-module}

This module is not a main processor in the default analysis chain, but it is used by the other modules that need access to the semantic database: The sense annotator <tt>senses</tt>, the word sense disambiguator <tt>ukb_wrap</tt>, the dependency parser <tt>dep_txala</tt>, and the coreference solver <tt>coref</tt>.

Moreover, this module can be used by the applications to enrich or post process the results of the analysis.

The API for this module is

```C++
class semanticDB {
  public:
    /// Constructor
    semanticDB(const std::string &); 

    /// Compute list of lemma-pos to search in WN for given word,
    /// according to mapping rules.
    void get_WN_keys(const std::wstring &, 
                     const std::wstring &, 
                     const std::wstring &,
                     std::list<std::pair<std::wstring,std::wstring> > &) const;

    /// get list of words for a sense+pos
    std::list<std::string> get_sense_words(const std::string &, 
                                           const std::string &) const;

    /// get list of senses for a lemma+pos
    std::list<std::string> get_word_senses(const std::string &, 
                                           const std::string &) const;

    /// get sense info for a sensecode+pos
    sense_info get_sense_info(const std::string &, const std::string &) const;
};
```

The constructor receives a configuration file, with the following contents:

*   A section `<WNPosMap>` which establishes which PoS found in the morphological dictionary should be mapped to each WN part-of-speech. Rule format is described below

*   A section `<DataFiles>` specifying the knowledge bases required by the algorithm. This section may contain up to three keywords, with the format:
    ```
    <DataFiles>
    senseDictFile  ./senses30.src
    wnFile  ../common/wn30.src
    formDictFile  ./dicc.src
    </DataFiles>
    ```

    `senseDictFile` is the sense repository, with the format described below.  
    `wnFile` is a file stating hyperonymy relations and other semantic information for each sense. The format is described below.  
    `formDictFile` may be needed if mapping rules in `<WNPosMap>` require it. It is a regular form dictionary file with morphological information, as described in section [Dictionary Search](dictionary.md).

## PoS mapping rules {#pos-mapping-rules}

Each line in section `<WNPosMap>` defines a mapping rule, with format  
`FreeLing-PoS WN-PoS search-key`  
where:
* `FreeLing-PoS` is a prefix for a FreeLing PoS tag
* `WN-Pos` must be one of `n`, `a`, `r`, or `v`
* `search-key` defines what should be used as a lemma to search the word in WN files.   
   The given `search-key` may be one of `L`, `F`, or a FreeLing PoS tag. If `L` (`F`) is given, the word lemma (form) will be searched in WN to find candidate senses. If a FreeLing PoS tag is given, the form for that lemma with the given tag will be used.

*Example 1:* For English, we could have a mapping like:
```
<WNposMap>
N n L
J a L
R r L
V v L
VBG a F
</WNposMap>
```
which states that for words with FreeLing tags starting with `N`, `J`, `R`, and `V`, lemma will be searched in wordnet with PoS `n`, `a`, `r`, and `v` respectively. It also states that words with tag `VBG` (e.g. _boring_) must be searched as adjectives (`a`) using their form (that is, _boring_ instead of its lemma _bore_). This may be useful, for instance, if FreeLing English dictionary assigns to that form a gerund analysis (`bore VBG`) but not an adjective one, and WordNet contains that word as an adjective.

*Example 2:* A similar example for Spanish, could be:
```
<WNposMap>
N n L
A a L
R r L
V v L
VMP a VMP00SM
</WNposMap>
```
which states that for words with FreeLing tags starting with `N`, `A`, `R`, and `V`, lemma will be searched in wordnet with PoS `n`, `a`, `r`, and `v` respectively. It also states that words with tag starting with `VMP` (e.g. _cansadas_) must be searched as adjectives (`a`) using the form for the same lema (i.e. _cansar_) that matches the tag `VMP00SM` (resulting in _cansado_). This is useful to have participles searched as adjectives, since FreeLing Spanish dictionary doesn't contain any participle as adjective, but esWN does.

## Sense Dictionary File {#sense-dictionary-file}

This source file (e.g. `senses30.src` provided with FreeLing) must contain the word list for each synset, one entry per line. 
Each line has format:   
`sense word1 word2 ...`   
E.g. 
`00045250-n actuation propulsion`   
`00050652-v assume don get_into put_on wear`

Sense codes can be anything (assuming your later processes know what to do with them) provided they are unambiguous (there are not two lines with the same sense code). The files provided in FreeLing contain WordNet 3.0 synset codes.

Words in the line can be multiwords, provided they are lowercased and glued toghether with underscores (see example above). Note that a multiword will only be found in the sense dictionary if it has been previously glued toghether by the [multiwords](locutions.md) module



## WordNet file {#wordnet-file}

This source file (e.g. `wn30.src` provided with FreeLing) must contain at each line the information relative to a sense, with the following format:  
`sense hypern:hypern:...:hypern  semfile  TopOnto:TopOnto:...:TopOnto  sumo  cyc`

That is: the first field is the sense code. The following fields are:

*   A colon-separated list of hypernym synsets.
*   WN semantic file the synset belongs to.
*   A colon-separated list of EuroWN TopOntology codes valid for the synset.
*   A code for an equivalent (or near) concept in SUMO ontology. See SUMO documentation for a description of the code syntax.
*   A code for an equivalent concept in OpenCyC ontology.

Note that the only WN relation encoded here is hypernymy. Note also that semantic codes such as WN semantic file or EWN TopOntology features are simply (lists of) strings. Thus, you can include in this file any ontological or semantic information you need, just substituing the WN-related codes by your own semantic categories.
