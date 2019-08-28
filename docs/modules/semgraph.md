
# Semantic Graph Extractor Module {#semantic-graph-extractor-module}

This module will combine the information provided by the parser, the SRL, and the coreference resolution modules, and build a semantic graph encoding which events are described in the text, which are the relations between them, and which are the actors participating in those events.

```C++
class semgraph_extract {

  public:
    /// Constructor   
    semgraph_extract(const std::wstring &CfgFile);    
    /// Destructor   
    ~semgraph_extract();

    /// extract graph from given document
    void extract(freeling::document &doc) const;

  };
```

This module will enrich the document with an object `semantic_graph` containing a pseudo entity-relationship model of the events described in the text.

For instance, for the text: _Mary says that Peter Smith bought a car that runs fast. Peter loves Mary._ FreeLing would produce the following graph:

```XML
<semantic_graph>
   <entity id="E1" lemma="mary" class="person">
      <mention id="t1.1" words="Mary" />
      <mention id="t2.3" words="Mary" />
   </entity>
   <entity id="E2" lemma="peter_smith" class="person" >
      <mention id="t1.4" words="Peter_Smith" />
      <mention id="t2.1" words="Peter" />
   </entity>
   <entity id="W6" lemma="car" sense="02958343-n" >
      <mention id="t1.7" words="a car that runs fast" />
      <synonym lemma="auto"/>
      <synonym lemma="automobile"/>
      <synonym lemma="car"/>
      <synonym lemma="machine"/>
      <synonym lemma="motorcar"/>
      <URI knowledgeBase="WordNet" 
           URI="http://wordnet-rdf.princeton.edu/wn30/02958343-n"/>
      <URI knowledgeBase="OpenCYC" 
           URI="http://sw.opencyc.org/concept/Mx4rvViVwZwpEbGdrcN5Y29ycA"/>
      <URI knowledgeBase="SUMO" 
           URI="http://ontologyportal.org/SUMO.owl#Automobile"/>
   </entity>
   <entity id="W8" lemma="fast" sense="00086000-r" >
      <mention id="t1.10" words="fast" />
      <synonym lemma="fast"/>
      <URI knowledgeBase="WordNet" 
           URI="http://wordnet-rdf.princeton.edu/wn30/00086000-r"/>
      <URI knowledgeBase="SUMO" 
           URI="http://ontologyportal.org/SUMO.owl#SubjectiveAssessmentAttribute"/>
   </entity>
   <frame id="F3" token="t1.2" lemma="say.00" sense="00928959-v" >
      <argument role="A0" entity="E1" />
      <argument role="A1" entity="F4" />
      <synonym lemma="say"/>
      <URI knowledgeBase="WordNet" 
           URI="http://wordnet-rdf.princeton.edu/wn30/00928959-v"/>
      <URI knowledgeBase="SUMO" 
           URI="http://ontologyportal.org/SUMO.owl#Process"/>
   </frame>
   <frame id="F4" token="t1.5" lemma="purchase.01|buy.01" sense="02207206-v" >
      <argument role="A0:Agent" entity="E2" />
      <argument role="A1:Theme" entity="W6" />
      <synonym lemma="buy"/>
      <synonym lemma="purchase"/>
      <URI knowledgeBase="WordNet" 
           URI="http://wordnet-rdf.princeton.edu/wn30/02207206-v"/>
      <URI knowledgeBase="OpenCYC" 
           URI="http://sw.opencyc.org/concept/Mx4rvVjL2pwpEbGdrcN5Y29ycA"/>
      <URI knowledgeBase="SUMO" 
           URI="http://ontologyportal.org/SUMO.owl#Buying"/>
   </frame>
   <frame id="F5" token="t1.9" lemma="run.00" sense="01926311-v" >
      <argument role="A0" entity="W6" />
      <argument role="AM-MNR" entity="W8" />
      <synonym lemma="run"/>
      <URI knowledgeBase="WordNet" 
           URI="http://wordnet-rdf.princeton.edu/wn30/01926311-v"/>
      <URI knowledgeBase="OpenCYC" 
           URI="http://sw.opencyc.org/concept/Mx4rvVjkGpwpEbGdrcN5Y29ycA"/>
      <URI knowledgeBase="SUMO" 
           URI="http://ontologyportal.org/SUMO.owl#Running"/>
   </frame>
   <frame id="F9" token="t2.2" lemma="love.01" sense="01775164-v" >
      <argument role="A0:Experiencer" entity="E2" />
      <argument role="A1:Stimulus" entity="E1" />
      <synonym lemma="love"/>
      <URI knowledgeBase="WordNet" 
           URI="http://wordnet-rdf.princeton.edu/wn30/01775164-v"/>
      <URI knowledgeBase="SUMO" 
           URI="http://ontologyportal.org/SUMO.owl#wants"/>
   </frame>
</semantic_graph>
```

The graph encodes that there are three entities in the text (_Peter_, _Mary_, and _a car_). Some of them are mentioned more than once (and so, they participate in different events described in the text). Some of them have a class (e.g. <tt>person</tt>) or a link to an external ontology (such as WN, SUMO, or OpenCYC).

Then, there are some events (or `frames`) described in the text. Those frames have arguments, which are the actors involved in each event. External URIs for the semantic of those actions are also provided.

So the main relations depicted in this example graph are:

*   Frame <tt>F9</tt> describes a <tt>love.01</tt> event experienced by entity <tt>E2</tt> (_Mary_) due to the stimulus of entity <tt>E1</tt> (_Peter_).
*   Frame <tt>F5</tt> describes a <tt>run.00</tt> event performed by entity <tt>W6</tt> (_a car_). This event has a manner argument that is <tt>W8</tt> (_fast_).
*   Frame <tt>F4</tt> describes a <tt>purchase.01|buy.01</tt> event performed by <tt>E2</tt> (_Peter_) on <tt>W6</tt> (_a car_).
*   Frame <tt>F3</tt> describes a <tt>say.00</tt> event where <tt>E1</tt> (_Mary_) states that event <tt>F4</tt> (Peter buying a car) happened.
