
# Input/Output handling modules {#input-output-handling-modules}

FreeLing package includes a few classes that can convert between FreeLing analyzed documents and an output representantion. New classes can be created by the user to meet specific needs.

The I/O handlers are derived from two top abstract classes: `input_handler` and `output_handler`.

Derived classes handle a particular I/O format, and must implement the appropriate methods.

```C++
class input_handler {

 public:   
   /// constructor. 
   input_handler ();
   /// destructor
   ~input_handler();

   /// load partially analyzed sentences from 'lines' into a list of sentences
   virtual void input_sentences(const std::wstring &lines, 
                                std::list<freeling::sentence> &ls) const = 0;
   /// load partially analyzed sentences from 'lines' into a document
   virtual void input_document(const std::wstring &lines, 
                               freeling::document &doc) const;
};
```

```C++
class output_handler {

 public:   
   /// empty constructor
   output_handler();
   /// destructor
   ~output_handler();

   /// load tagset rules for PoS shortening and MSD descriptions
   void load_tagset(const std::wstring &ftag);
   /// set language 
   void set_language(const std::wstring &lg);

   /// Print appropriate header for the output 
   /// format (e.g. XML header or tag opening)
   virtual void PrintHeader(std::wostream &sout) const;
   /// print appropriate footer (e.g. close XML tags)
   virtual void PrintFooter(std::wostream &sout) const; 
   /// print given sentences to sout in appropriate format (no headers)
   virtual void PrintResults(std::wostream &sout,
                             const std::list<freeling::sentence> &ls) const=0;
   virtual std::wstring PrintResults(const std::list<freeling::sentence> &ls) const;

   /// print given document to sout in appropriate format, including headers.
   virtual void PrintResults(std::wostream &sout, 
                             const freeling::document &doc) const = 0;
   virtual std::wstring PrintResults (const freeling::document &doc) const;
};
```

## Output handlers {#output-handlers}

Currently, the following output handlers are implemented. All of them are derived from `output_handler`.

### FreeLing Output

The module `output_freeling` produces the classical FreeLing output (column-like for lower analysis levels, and parenthesized trees for higher levels). The desired output can be configured by the calling application activating or deactivating print levels.

```C++
class output_freeling : public output_handler {
 public:   
   // constructor. 
   output_freeling ();
   output_freeling(const std::wstring &cfgFile);
   ~output_freeling ();

   /// output a parse tree
   void PrintTree (std::wostream &sout, 
                   freeling::parse_tree::const_iterator n, 
                   int depth) const;
   /// output a dependency tree
   void PrintDepTree (std::wostream &sout, 
                      freeling::dep_tree::const_iterator n, 
                      int depth) const;
   /// output a predicate structure 
   void PrintPredArgs (std::wostream &sout, 
                       const freeling::sentence &s) const;
   /// output a word and its morphological information
   void PrintWord (std::wostream &sout, 
                   const freeling::word &w, 
                   bool only_sel=true, 
                   bool probs=true) const;
   /// Output coreference groups
   void PrintCorefs(std::wostream &sout, 
                    const freeling::document &doc) const;
   /// Output semantic Graph
   void PrintSemgraph(std::wostream &sout, 
                      const freeling::document &doc) const;

   /// print given sentences to sout in appropriate format
   void PrintResults (std::wostream &sout, 
                      const std::list<freeling::sentence> &ls) const;
   /// print given document to sout in appropriate format
   void PrintResults(std::wostream &sout, 
                     const freeling::document &doc) const;

   /// inherit other methods from abstract class
   using output_handler::PrintResults;

   // activate/deactivate printing levels
   void output_senses(bool);
   void output_all_senses(bool);
   void output_phonetics(bool);
   void output_dep_tree(bool);
   void output_corefs(bool);  
   void output_semgraph(bool);
};
```

### CoNLL Output

The module `output_conll` produces a CoNLL-like column format. The default format is not exactly any of the CoNLL competitions, but an adapted version.

The module will always print all information avaliable in the document (i.e. if the document is parsed, a column for the parse tree will be generated).

The constructor may be called with a configuration file stating which columns should be printed and in which order.
The configuration file must contain a section `<Type>` containing just the keyword `conll` (just to explicit that this file is for this kind of output_handler), as well as a section `<Columns>` specifying the list of columns that must appear in the output, and in which order.
The file may also contain a section `<TagsetFile>` pointing which [tagset definition](tagset.md) file should be used (this section is only required if `SHORT_TAG` or `MSD` are specified in the `<Columns>` section. 

The default behaviour of this module (that is, if no configuration file is provided), is the same than with the configuration file:
```XML
<Type>
conll
</Type>
<TagsetFile>
./tagset.dat
</TagsetFile>
<Columns>
ID FORM LEMMA TAG SHORT_TAG MSD NEC SENSE SYNTAX DEPHEAD DEPREL COREF SRL
</Columns>
```

Valid column names are:
* `ID`: token id (position of word in the sentence)
* `SPAN_BEGIN`: character position of the word in the original text.
* `SPAN_END`:  character position of the end of word in the original text.
* `FORM`: word form
* `LEMMA`: word lemma
* `TAG`: Complete PoS tag
* `SHORT_TAG`: Short Pos tag (as shortened by the [Tagset definition](tagset.md) file)
* `MSD`: Morphosyntactic features (as produced by the [Tagset definition](tagset.md) file)
* `NEC`: Named Entity Classifier output in B-I-O format
* `SENSE`: Sense selected by the used WSD module (or first sense if no disambiguation was used)
* `ALL_SENSES`: List of all possible senses for the word
* `SYNTAX`: Information about constituents opening/closing in this word
* `DEPHEAD`: Head of the word in the dependency tree
* `DEPREL`: Syntactic function of the word with regard to its head.
* `COREF`: Coreference groups opening/closing in this word
* `SRL`: Semantic Role Labelling predicates and arguments in CoNLL format. This may take more than one column, and must always be the last field in the list.
* `USERx`: (where `x` is a number) Content of the `x`-th position in the `user` vector of each word (this vector is ignored by FreeLing, it is intended for the user application to store any needed information).

```C++
class output_conll : public output_handler {

 public:   
   /// empty constructor. 
   output_conll ();
   /// constructor from cfg file
   output_conll (const std::wstring &cfgFile);
   /// destructor. 
   ~output_conll ();

   /// Fill conll_sentence from freeling::sentence
   void freeling2conll(const freeling::sentence &s, 
                       conll_sentence &cs) const;

   /// print given sentences to sout in appropriate format
   void PrintResults (std::wostream &sout, 
                      const std::list<freeling::sentence> &ls) const;
   /// print given a document to sout in appropriate format
   void PrintResults(std::wostream &sout, 
                     const freeling::document &doc) const;
   /// inherit other methods
   using output_handler::PrintResults;
};
```

### XML Output

The module `output_xml` produces an XML representation of the analyzed document.

The module will always print all information avaliable in the document (i.e. if the document is parsed, an XML tag for the parse tree will be generated).

```C++
class output_xml : public output_handler {

 public:   
   /// constructor. 
   output_xml ();
   output_xml (const std::wstring &cfgFile);
   /// destructor. 
   ~output_xml ();

   /// print XML file header
   void PrintHeader(std::wostream &sout) const; 
   /// print XML file footer
   void PrintFooter(std::wostream &sout) const; 

   /// print given sentences to sout in appropriate format
   void PrintResults (std::wostream &sout, 
                      const std::list<freeling::sentence> &ls) const;
   /// print given a document to sout in appropriate format
   void PrintResults(std::wostream &sout, 
                     const freeling::document &doc) const;
   /// inherit other methods
   using output_handler::PrintResults;
};
```

The Schema for the XML generated by this module is:
```XML
<xs:schema attributeFormDefault="unqualified" elementFormDefault="qualified" xmlns:xs="http://www.w3.org/2001/XMLSchema">


  <!-- ************************************ -->
  <!-- Type definition for parse tree nodes -->
  <!-- ************************************ -->
  <xs:complexType name="nodeType">
    <!-- Each node can have list of child nodes -->
    <xs:sequence>
      <xs:element name="node" type="nodeType" minOccurs="0" maxOccurs="unbounded"/>
    </xs:sequence>
    <!-- Content of the tree nodes -->
    <xs:attribute type="xs:boolean" name="leaf" use="optional"/>
    <xs:attribute type="xs:boolean" name="head" use="optional"/>
    <xs:attribute type="xs:string" name="label" use="optional"/>
    <xs:attribute type="xs:string" name="token" use="optional"/>
    <xs:attribute type="xs:string" name="word" use="optional"/>
  </xs:complexType>

  <!-- ***************************************** -->
  <!-- Type definition for dependency tree nodes -->
  <!-- ***************************************** -->
  <xs:complexType name="depnodeType">
    <!-- Each node can have list of child nodes -->
    <xs:sequence>
      <xs:element name="depnode" type="depnodeType" minOccurs="0" maxOccurs="unbounded"/>
    </xs:sequence>
    <!-- Content of the dep tree nodes -->
    <xs:attribute type="xs:string" name="token" use="optional"/>
    <xs:attribute type="xs:string" name="function" use="optional"/>
    <xs:attribute type="xs:string" name="word" use="optional"/>
  </xs:complexType> 


  <!-- ************************************* -->
  <!-- **         MAIN DOCUMENT           ** -->
  <!-- ************************************* -->
  <xs:element name="document">
    <xs:complexType>
 
      <!-- A document contains paragraphs, coreferences, and semantic_graph -->
      <xs:sequence>

      <!-- paragraphs -->
      <xs:sequence>
        <xs:element name="paragraph" maxOccurs="unbounded" minOccurs="1">
          <xs:complexType>

            <!-- A paragraph contains a list of sentences -->
            <xs:sequence>
              <xs:element name="sentence" maxOccurs="unbounded" minOccurs="1">
                <xs:complexType>

                  <!-- a sentence contains tokens, parse_tree, dep_tree, and predicates -->
                  <xs:sequence>

                  <!-- A sentence contains a list of tokens -->
                  <xs:sequence>
                    <xs:element name="token" maxOccurs="unbounded" minOccurs="1">
                      <xs:complexType>
                         <xs:sequence>
                           <xs:element name="analysis" maxOccurs="unbounded" minOccurs="0"> 
                           <xs:complexType>
                             <xs:attribute type="xs:string" name="lemma" use="optional"/>
                             <xs:attribute type="xs:string" name="tag" use="optional"/>
                             <xs:attribute type="xs:string" name="ctag" use="optional"/>
                             <xs:attribute type="xs:string" name="pos" use="optional"/>
                             <xs:attribute type="xs:string" name="vform" use="optional"/>
                             <xs:attribute type="xs:string" name="wn" use="optional"/>
                             <xs:attribute type="xs:string" name="type" use="optional"/>
                             <xs:attribute type="xs:string" name="punctenclose" use="optional"/>
                             <xs:attribute type="xs:string" name="num" use="optional"/>
                             <xs:attribute type="xs:string" name="person" use="optional"/>
                             <xs:attribute type="xs:string" name="neclass" use="optional"/>
                             <xs:attribute type="xs:string" name="nec" use="optional"/>
                             <xs:attribute type="xs:double" name="prob" use="optional"/>
                           </xs:complexType>
                           </xs:element> 
                         </xs:sequence>
                        <xs:attribute type="xs:string" name="id" use="required"/>
                        <xs:attribute type="xs:string" name="form" use="required"/>
                        <xs:attribute type="xs:string" name="phon" use="optional"/>
                        <xs:attribute type="xs:string" name="lemma" use="optional"/>
                        <xs:attribute type="xs:string" name="tag" use="optional"/>
                        <xs:attribute type="xs:string" name="ctag" use="optional"/>
                        <xs:attribute type="xs:string" name="pos" use="optional"/>
                        <xs:attribute type="xs:string" name="vform" use="optional"/>
                        <xs:attribute type="xs:string" name="wn" use="optional"/>
                        <xs:attribute type="xs:string" name="type" use="optional"/>
                        <xs:attribute type="xs:string" name="punctenclose" use="optional"/>
                        <xs:attribute type="xs:string" name="num" use="optional"/>
                        <xs:attribute type="xs:string" name="person" use="optional"/>
                        <xs:attribute type="xs:string" name="neclass" use="optional"/>
                        <xs:attribute type="xs:string" name="nec" use="optional"/>
                      </xs:complexType>
                    </xs:element>
                  </xs:sequence>

                  <!-- A sentence may contain a parse_tree -->
                  <xs:sequence>
                    <xs:element name="constituents" minOccurs="0" maxOccurs="1">
                      <xs:complexType>
                        <!-- The tree contains just a root node -->
                        <xs:all>
                          <xs:element name="node" type="nodeType" />
                        </xs:all>
                      </xs:complexType>
                    </xs:element>
                  </xs:sequence>

                  <!-- A sentence may contain a dependency tree -->
                  <xs:sequence>
                    <xs:element name="dependencies" minOccurs="0" maxOccurs="1">
                      <xs:complexType>
                        <!-- The tree contains just a root node -->
                        <xs:all>
                          <xs:element name="depnode" type="depnodeType" />
                        </xs:all>
                      </xs:complexType>
                    </xs:element>
                  </xs:sequence>
                    
                  <!-- A sentence may contain a list of predicates -->
                  <xs:sequence>
                    <xs:element name="predicates" maxOccurs="1" minOccurs="0">
                      <xs:complexType>
                        <xs:sequence>
                          <xs:element name="predicate" maxOccurs="unbounded" minOccurs="1">
                            <xs:complexType mixed="true">

                              <!-- A predicate may contain a list of arguments -->
                              <xs:sequence>
                                <xs:element name="argument" maxOccurs="unbounded" minOccurs="0">
                                  <xs:complexType>
                                    <!-- Argument information -->
                                    <xs:simpleContent>
                                      <xs:extension base="xs:string">
                                        <xs:attribute type="xs:string" name="role" use="optional"/>
                                        <xs:attribute type="xs:string" name="words" use="optional"/>
                                        <xs:attribute type="xs:string" name="head_token" use="optional"/>
                                        <xs:attribute type="xs:string" name="from" use="optional"/>
                                        <xs:attribute type="xs:string" name="to" use="optional"/>
                                      </xs:extension>
                                    </xs:simpleContent>
                                  </xs:complexType>
                                </xs:element>
                              </xs:sequence>

                              <!-- Predicate information -->
                              <xs:attribute type="xs:string" name="id" use="optional"/>
                              <xs:attribute type="xs:string" name="head_token" use="optional"/>
                              <xs:attribute type="xs:string" name="sense" use="optional"/>
                              <xs:attribute type="xs:string" name="words" use="optional"/>
  
                            </xs:complexType>
                          </xs:element>
                        </xs:sequence>
                      </xs:complexType>
                    </xs:element>
                    <!-- End of 'predicates' element -->

                  </xs:sequence>
                  <!-- End of 'predicates' list -->

                  </xs:sequence>
                  <!-- End of sentence subelements --> 

                  <!-- 'sentence' element attributes -->
                  <xs:attribute type="xs:string" name="id" use="required"/>

                </xs:complexType>
              </xs:element>
              <!-- End of 'sentence' element -->

            </xs:sequence>
            <!-- End of list of sentences in paragraph -->

          </xs:complexType>
        </xs:element>
        <!-- End of 'paragraph' element -->

      </xs:sequence>
      <!-- End of list of paragraphs in document -->

      <!-- A document may contain a list of coreference sets -->
      <xs:sequence>
        <xs:element name="coreferences" maxOccurs="1" minOccurs="0">
          <xs:complexType>
            <xs:sequence>
              <xs:element name="coref" maxOccurs="unbounded" minOccurs="1">
                <xs:complexType>	
   	          <!-- A coreference group contains a list of mentions -->
                  <xs:sequence>
                    <xs:element name="mention" maxOccurs="unbounded" minOccurs="1">
                      <xs:complexType>
                            <xs:attribute type="xs:string" name="id" use="required"/>
                            <xs:attribute type="xs:string" name="from" use="required"/>
                            <xs:attribute type="xs:string" name="to" use="required"/>
                            <xs:attribute type="xs:string" name="words" use="required"/>
                      </xs:complexType>
                    </xs:element>
                  </xs:sequence>
                  <!-- Coreference group information -->
                  <xs:attribute type="xs:string" name="id" use="required"/>
                </xs:complexType>
              </xs:element>
            </xs:sequence>
          </xs:complexType>
        </xs:element>
      </xs:sequence>
      <!-- End of 'coreferece' element in document -->

      <!-- A document may contain a semantic graph -->
      <xs:sequence>
        <xs:element name="semantic_graph" maxOccurs="1" minOccurs="0">
          <xs:complexType>

            <!-- A semantic graph contains a list of 'entities' and 'frames' -->
            <xs:sequence>

              <!-- 'entity' elements in the graph -->
              <xs:element name="entity" maxOccurs="unbounded" minOccurs="0">
                <xs:complexType>

                  <xs:sequence>       
                  <!-- Entity contains a list of mentions -->
                  <xs:sequence>
                    <xs:element name="mention" maxOccurs="unbounded" minOccurs="0">
                      <xs:complexType>
                        <xs:simpleContent>
                          <!-- Basic mention information -->
                          <xs:extension base="xs:string">
                            <xs:attribute type="xs:string" name="id" use="optional"/>
                            <xs:attribute type="xs:string" name="words" use="optional"/>
                          </xs:extension>
                        </xs:simpleContent>
                      </xs:complexType>
                    </xs:element>
                  </xs:sequence>

                  <!-- Entity may contains a list of synonyms -->
                  <xs:sequence>
                    <xs:element name="synonym" maxOccurs="unbounded" minOccurs="0">
                      <xs:complexType>
                        <xs:simpleContent>
                          <xs:extension base="xs:string">
                            <xs:attribute type="xs:string" name="lemma" use="optional"/>
                          </xs:extension>
                        </xs:simpleContent>
                      </xs:complexType>
                    </xs:element>
                  </xs:sequence>

                  <!-- Entity may contains a list of URI -->
                  <xs:sequence>
                    <xs:element name="URI" maxOccurs="unbounded" minOccurs="0">
                      <xs:complexType>
                        <xs:simpleContent>
                          <xs:extension base="xs:string">
                            <xs:attribute type="xs:string" name="knowledgeBase" use="optional"/>
                            <xs:attribute type="xs:anyURI" name="URI" use="optional"/>
                          </xs:extension>
                        </xs:simpleContent>
                      </xs:complexType>
                    </xs:element>
                  </xs:sequence>
                  </xs:sequence>       

                  <!-- Basic entity information -->
                  <xs:attribute type="xs:string" name="id" use="required"/>
                  <xs:attribute type="xs:string" name="lemma" use="required"/>
                  <xs:attribute type="xs:string" name="class" use="optional"/>
                  <xs:attribute type="xs:string" name="sense" use="optional"/>

                </xs:complexType>
              </xs:element>
              <!-- End of 'entity' element -->

              <!-- 'frame' elements in the graph -->
              <xs:element name="frame" maxOccurs="unbounded" minOccurs="0">
                <xs:complexType>

                  <xs:sequence>
                  <!-- Frame may contain a list of arguments -->
                  <xs:sequence>
                    <xs:element name="argument" maxOccurs="unbounded" minOccurs="0">
                      <xs:complexType>
                        <xs:simpleContent>
                          <xs:extension base="xs:string">
                            <xs:attribute type="xs:string" name="role" use="optional"/>
                            <xs:attribute type="xs:string" name="entity" use="optional"/>
                          </xs:extension>
                        </xs:simpleContent>
                      </xs:complexType>
                    </xs:element>
                  </xs:sequence>

                  <!-- Frame may contains a list of synonyms -->
                  <xs:sequence>
                    <xs:element name="synonym" maxOccurs="unbounded" minOccurs="0">
                      <xs:complexType>
                        <xs:simpleContent>
                          <xs:extension base="xs:string">
                            <xs:attribute type="xs:string" name="lemma" use="optional"/>
                          </xs:extension>
                        </xs:simpleContent>
                      </xs:complexType>
                    </xs:element>
                  </xs:sequence>

                  <!-- Frame may contains a list of URI -->
                  <xs:sequence>
                    <xs:element name="URI" maxOccurs="unbounded" minOccurs="0">
                      <xs:complexType>
                        <xs:simpleContent>
                          <xs:extension base="xs:string">
                            <xs:attribute type="xs:string" name="knowledgeBase" use="optional"/>
                            <xs:attribute type="xs:anyURI" name="URI" use="optional"/>
                          </xs:extension>
                        </xs:simpleContent>
                      </xs:complexType>
                    </xs:element>
                  </xs:sequence>
                  </xs:sequence>

                  <!-- Basic frame information -->
                  <xs:attribute type="xs:string" name="id" use="required"/>
                  <xs:attribute type="xs:string" name="token" use="required"/>
                  <xs:attribute type="xs:string" name="lemma" use="required"/>
                  <xs:attribute type="xs:string" name="sense" use="optional"/>

                </xs:complexType>
              </xs:element>
              <!-- End of 'Frame' element in semantic graph -->

            </xs:sequence>
            <!-- End of list of frames and entities in semantic graph -->

        </xs:complexType>
      </xs:element>
      </xs:sequence>
      <!-- End of semantic graph element -->

      </xs:sequence>
    </xs:complexType>
  </xs:element>
  <!-- End of 'document' element -->

</xs:schema>
```

### JSON Output

The module `output_json` produces a JSON object for the analyzed document.

The module will always print all information avaliable in the document (i.e. if the document is parsed, an JSON object for the parse tree will be included in the document object).

```C++
class output_json : public output_handler {

 public:   
   // constructor. 
   output_json ();
   output_json (const std::wstring &cfgFile);
   // destructor. 
   ~output_json ();

   // print given sentences to sout in appropriate format
   void PrintResults (std::wostream &sout, 
                      const std::list<freeling::sentence> &ls) const;
   // print given a document to sout in appropriate format
   void PrintResults(std::wostream &sout, 
                     const freeling::document &doc) const;
   /// inherit other methods
   using output_handler::PrintResults;
};
```

The schema for the output produced by this module is:
```JSON
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "id": "FreeLing Analyzed Document",

  "type": "object",
  "properties": {
    "paragraphs": {
      "type": "array",
      "items": {
        "id": "paragraph",
        "type": "object",
        "properties": {
          "sentences": {
            "type": "array",
            "items": [
              {
                "id": "sentence",
                "type": "object",
                "properties": {
                  "id": { "type": "string" },
                  "tokens": {
                    "id": "tokens",
                    "type": "array",
                    "items": [
                      {
                        "type": "object",
                        "properties": {
                          "id": { "type": "string" },
                          "form": {"type": "string" },
                          "lemma": {"type": "string" },
                          "tag": { "type": "string" },
                          "ctag": { "type": "string" },
                          "pos": { "type": "string" },
                          "type": { "type": "string" },
                          "gen": { "type": "string" },
                          "num": { "type": "string" },
                          "wn": { "type": "string" },
                          "neclass": { "type": "string" },
                          "nec": { "type": "string" },
                          "mood": { "type": "string" },
                          "tense": { "type": "string" },
                          "person": { "type": "string" }
                        }
                      }
                    ]
                  }, 
                  "constituents": {
                    "id": "constituents",
                    "type": "array",
                    "items": {
                      "type": "object",
                      "properties": {
                        "label": { "type": "string" },
                        "head": { "type": "string" },
                        "children": {
	                  "type" : "object",
                          "$ref" : "constituents"
                        }
                      }
                    }
                  },
                  "dependencies": {
                    "id": "dependencies",
                    "type": "object",
                    "properties": {
                      "token": { "type": "string" },
                      "function": { "type": "string" },
                      "word": { "type": "string" },
                      "children": {
                        "type": "array",
                        "items": [
                           {
                             "type": "object",
	                     "$ref": "dependencies"
                           }
                        ]
                      }
                    }
                  },
                  "predicates": {
                    "type": "array",
                    "items": [
                      {
                        "id": "predicate",
                        "type": "object",
                        "properties": {
                          "id": { "type": "string" },
                          "head_token": { "type": "string" },
                          "sense": { "type": "string" },
                          "words": { "type": "string" },
                          "arguments": {
                            "type": "array",
                            "items": [
                              {
                                "type": "object",
                                "properties": {
                                  "role": { "type": "string" },
                                  "words": { "type": "string" },
                                  "head_token": { "type": "string" },
                                  "from": { "type": "string" },
                                  "to": { "type": "string" }
                                }
                              }
                            ]
                          }
                        }
                      }
                    ]
                  }
                },
                "required": [
                  "id",
                  "tokens"
                ]
              }
            ]
          }
        },
        "required": [
          "sentences"
        ]
      }
    },
    "coreferences": {
      "id": "coreferences",
      "type": "array",
      "items": [
        {
          "type": "object",
          "properties": {
            "id": { "type": "string" },
            "mentions": {
              "type": "array",
              "items": [
                {
                  "type": "object",
                  "properties": {
                    "id": { "type": "string" },
                    "from": { "type": "string" },
                    "to": { "type": "string" },
                    "words": { "type": "string" }
                 }
                }
              ]
            }
          }
        }
      ]
    },
    "semantic_graph": {
      "id": "semantic_graph",
      "type": "array",
      "items": [
        {
          "id": "entity",
          "type": "object",
          "properties": {
            "id": {  "type": "string" },
            "lemma": { "type": "string" },
            "class": { "type": "string" },
            "sense": { "type": "string" },
            "mentions": {
              "type": "array",
              "items": [
                {
                  "type": "object",
                  "properties": {
                    "id": { "type": "string" },
                    "from": { "type": "string" },
                    "to": { "type": "string" },
                    "words": { "type": "string" }
                 }
                }
              ]
            },
            "synonyms": {
              "type": "array",
              "items": [
                { "type": "string" }
              ]
            },
            "URIs": {
              "type": "array",
              "items": [
                {
                  "type": "object",
                  "properties": {
                    "knowledgeBase": { "type": "string" },
                    "URI": { "type": "string" }
                  }
                }
              ]
            }
          }
        },
        {
          "id": "frame",
          "type": "object",
          "properties": {
            "id": { "type": "string" },
            "token": { "type": "string" },
            "lemma": { "type": "string" },
            "sense": { "type": "string" },
            "arguments": {
              "type": "array",
              "items": [
                {
                  "type": "object",
                  "properties": {
                    "role": { "type": "string" },
                    "entity": { "type": "string" }
                  }
                }
              ]
            },
            "synonyms": {
              "type": "array",
              "items": [
                { "type": "string" }
              ]
            },
            "URIs": {
               "type": "array",
               "items": [
                {
                  "type": "object",
                  "properties": {
                    "knowledgeBase": { "type": "string" },
                    "URI": { "type": "string" }
                  }
                 }
               ]
            }            
          }
        }
      ]
    }
  },
  "required": [
    "paragraphs",
  ]
}
```

### NAF Output

The module `output_naf` produces a NAF [\[FSB+14\]](../references.md) representation for the analyzed document.

The desired output can be configured by the calling application activating or deactivating annotation layers.

```C++
class output_naf : public output_handler {
 public:   
   // constructor. 
   output_naf ();
   output_naf (const std::wstring &cfgFile);
   // destructor. 
   ~output_naf ();

   // print given sentences to sout in appropriate format
   void PrintResults (std::wostream &sout, 
                      const std::list<freeling::sentence> &ls) const;
   // print given a document to sout in appropriate format
   void PrintResults(std::wostream &sout, 
                     const freeling::document &doc) const;
   /// inherit other methods
   using output_handler::PrintResults;

   // print NAF header
   void PrintHeader(std::wostream &sout) const;
   // print NAF footer
   void PrintFooter(std::wostream &sout) const; 

   // activate/deactivate layer for next printings
   void ActivateLayer(const std::wstring &ly, bool b);
};
```

The module `output_train` produces a FreeLing specific format suitable to be used to retrain the PoS tagger (tipically after hand correction of the tagger errors).

```C++
class output_train : public output_handler {

 public:   
   // constructor. 
   output_train ();
   ~output_train ();

   void PrintWord (std::wostream &sout, 
                   const freeling::word &w, 
                   bool only_sel=true, 
                   bool probs=true) const;
   // print given sentences to sout in appropriate format
   void PrintResults (std::wostream &sout, 
                      const std::list<freeling::sentence> &ls) const;
   // print given a document to sout in appropriate format
   void PrintResults(std::wostream &sout, 
                     const freeling::document &doc) const;
   /// inherit other methods
   using output_handler::PrintResults;
};
```


## Input handlers {#output-handlers}

Currently, the following output handlers are implemented. All of them are derived from `input_handler`.

### FreeLing Input

  This class will load output produced by FreeLing with `--outlv morfo` or `--outlv tagged`. 

```C++
class input_freeling : public input_handler {      
 public:   
  // constructor. 
  input_freeling ();
  // destructor. 
  ~input_freeling ();

  /// load partially analyzed sentences from 'lines' into a list of sentences
  virtual void input_sentences(const std::wstring &lines, 
                               std::list<freeling::sentence> &ls) const;

  /// load partially analyzed sentences from 'lines' into a document
  virtual void input_document(const std::wstring &lines, 
                               freeling::document &doc) const;

};
```


### CoNLL  Input

  This class will load output produced by `output_conll` (see above).

  A configuration file can be provided to the constructor. 
  The configuration file format is the same than for `output_conll`.

```C++
class input_conll : public input_handler, public conll_handler {

 public:   
  // default constructor. 
  input_conll();
  // constructor from config file
  input_conll(const std::wstring &fcfg);
  // destructor. 
  ~input_conll();

  void input_sentences(const std::wstring &lines, std::list<freeling::sentence> &ls) const;
  void input_document(const std::wstring &lines, freeling::document &doc) const;
};
```

The default behaviour of this module (that is, if no configuration file is provided), is the same than with the configuration file:

```XML
<TagsetFile>
./tagset.dat
</TagsetFile>
<Columns>
ID FORM LEMMA TAG SHORT_TAG MSD NEC SENSE SYNTAX DEPHEAD DEPREL COREF SRL
</Columns>
```
