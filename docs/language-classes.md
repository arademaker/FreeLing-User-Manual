# Linguistic Information Storage Classes {#linguistic-information-storage-classes}

FreeLing library processes text and creates data structures that represent the linguistic objects in that text. Linguistic objects are elements like word, PoS-tag, sentence, parse_tree, etc.

Thus, FreeLing processing modules are able to convert a text into a collection of linguistic objects.

Processing modules typically receive some of these objects (e.g. a sentence, consisting of a list of words) and enrich it with additional information (e.g. adding PoS-tags to the words in the sentece, or a parse_tree to the sentence). Processing modules are described in section [Language Processing Modules](#language-processing-modules).

This chapter describes the classes where all this linguistic information is stored by the processing modules. The application calling FreeLing can later access this data structures to retrieve the results of the analyzers.

# Classes <tt>word</tt> and <tt>analysis</tt> {#classes-word-and-analysis}

The basic bricks of language are words, and this is the basic class that FreeLing uses to represent data.

Class <tt>word</tt> can store the form of a word (so, how it was written in the text), its phonetic encoding, and other information about it.

Many words are ambiguous with respect to their Part-of-Speech. For instance, the English word *bit* may be either a noun (a small piece of something) or a verb (past tense of verb *to bite*). Often, these different PoS tags are associated to different lemmas (e.g. *bit* for the noun reading and *bite* for the verb interpretation).

Thus, class <tt>word</tt> also stores a list of <tt>analysis</tt> objects. Every <tt>analysis</tt> is basically a combination of one lemma and one PoS tag. Analysis also may contain other information such as a list of senses, a probability, etc.

The word also stores information about which analysis were selected by the tagger, whether the word is a multiword made by the agglutination of several input tokens, etc. It also offers iterators to traverse the list of analysis of the word, either all of them, or only the subset selected (or non-selected) by the tagger.

The API for the class word is:

```C++
class word : public std::list<analysis> {

  public:
    /// user-managed data, we just store it.
    std::vector<std::wstring> user;

    /// constructor
    word();
    /// constructor
    word(const std::wstring &);
    /// constructor
    word(const std::wstring &, const std::list<word> &);
    /// constructor
    word(const std::wstring &, const std::list<analysis> &, const std::list<word> &);
    /// Copy constructor
    word(const word &);
    /// assignment
    word& operator=(const word&);

    /// copy analysis from another word
    void copy_analysis(const word &);
    /// Get the number of selected analysis
    int get_n_selected(int k=0) const;
    /// get the number of unselected analysis
    int get_n_unselected(int k=0) const;
    /// true iff the word is a multiword compound
    bool is_multiword() const;
    /// true iff the word is a multiword marked as ambiguous
    bool is_ambiguous_mw() const;
    /// set mw ambiguity status
    void set_ambiguous_mw(bool);
    /// get number of words in compound
    int get_n_words_mw() const;
    /// get word objects that form the multiword
    const std::list<word>& get_words_mw() const;
    /// get word form
    const std::wstring& get_form() const;
    /// Get word form, lowercased.
    const std::wstring& get_lc_form() const;
    /// Get word phonetic form
    const std::wstring& get_ph_form() const;
    /// Get an iterator to the first selected analysis
    word::iterator selected_begin(int k=0);
    /// Get an iterator to the first selected analysis
    word::const_iterator selected_begin(int k=0) const;
    /// Get an iterator to the end of selected analysis list
    word::iterator selected_end(int k=0);
    /// Get an iterator to the end of selected analysis list
    word::const_iterator selected_end(int k=0) const;
    /// Get an iterator to the first unselected analysis
    word::iterator unselected_begin(int k=0);
    /// Get an iterator to the first unselected analysis
    word::const_iterator unselected_begin(int k=0) const;
    /// Get an iterator to the end of unselected analysis list
    word::iterator unselected_end(int k=0);
    /// Get an iterator to the end of unselected analysis list
    word::const_iterator unselected_end(int k=0) const;
    /// Get how many kbest tags the word has
    unsigned int num_kbest() const;
    /// get lemma for the selected analysis in list
    const std::wstring& get_lemma(int k=0) const;
    /// get tag for the selected analysis
    const std::wstring& get_tag(int k=0) const;

    /// get sense list for the selected analysis
    const std::list<std::pair<std::wstring,double> >& get_senses(int k=0) const;
    std::list<std::pair<std::wstring,double> >& get_senses(int k=0);
    // useful for java API
    std::wstring get_senses_string(int k=0) const;
    /// set sense list for the selected analysis
    void set_senses(const std::list<std::pair<std::wstring,double> > &, int k=0);

    /// get token span.
    unsigned long get_span_start() const;
    unsigned long get_span_finish() const;

    /// get in_dict
    bool found_in_dict() const;
    /// set in_dict
    void set_found_in_dict(bool);
    /// check if there is any retokenizable analysis
    bool has_retokenizable() const;
    /// mark word as having definitive analysis
    void lock_analysis();
    /// check if word is marked as having definitive analysis
    bool is_locked() const;

    /// add an alternative to the alternatives list
    void add_alternative(const std::wstring &, int);
    /// replace alternatives list with list given
    void set_alternatives(const std::list<std::pair<std::wstring,int> > &);
    /// clear alternatives list
    void clear_alternatives();
    /// find out if the speller checked alternatives
    bool has_alternatives() const;
    /// get alternatives list const &
    const std::list<std::pair<std::wstring,int> >& get_alternatives() const;
    /// get alternatives list &
    std::list<std::pair<std::wstring,int> >& get_alternatives();
    /// get alternatives begin iterator
    std::list<std::pair<std::wstring,int> >::iterator alternatives_begin();
    /// get alternatives end iterator
    std::list<std::pair<std::wstring,int> >::iterator alternatives_end();
    /// get alternatives begin iterator
    std::list<std::pair<std::wstring,int> >::const_iterator alternatives_begin() const;
    /// get alternatives end iterator
    std::list<std::pair<std::wstring,int> >::const_iterator alternatives_end() const;

    /// add one analysis to current analysis list  (no duplicate check!)
    void add_analysis(const analysis &);
    /// set analysis list to one single analysis, overwriting current values
    void set_analysis(const analysis &);
    /// set analysis list, overwriting current values
    void set_analysis(const std::list<analysis> &);
    /// set word form
    void set_form(const std::wstring &);
    /// Set word phonetic form
    void set_ph_form(const std::wstring &);
    /// set token span
    void set_span(unsigned long, unsigned long);

    // get/set word position
    void set_position(size_t);
    size_t get_position() const;

    /// look for an analysis with a tag matching given regexp
    bool find_tag_match(const freeling::regexp &) const;

    /// get number of analysis in current list
    int get_n_analysis() const;
    /// empty the list of selected analysis
    void unselect_all_analysis(int k=0);
    /// mark all analysisi as selected
    void select_all_analysis(int k=0);
    /// add the given analysis to selected list.
    void select_analysis(word::iterator, int k=0);
    /// remove the given analysis from selected list.
    void unselect_analysis(word::iterator, int k=0);
    /// get list of analysis (useful for perl API)
    std::list<analysis> get_analysis() const;
    /// get begin iterator to analysis list (useful for perl/java API)
    word::iterator analysis_begin();
    word::const_iterator analysis_begin() const;
    /// get end iterator to analysis list (useful for perl/java API)
    word::iterator analysis_end();
    word::const_iterator analysis_end() const;
  };
```

Since a large amount of useful information about the word is stored in the analysis it contains, the class <tt>analysis</tt> also offers methods to access its content:

```C++
class analysis {

  public:
    /// user-managed data, we just store it.
    std::vector<std::wstring> user;

    /// constructor
    analysis();
    /// constructor
    analysis(const std::wstring &, const std::wstring &);
    /// assignment
    analysis& operator=(const analysis&);

    void init(const std::wstring &l, const std::wstring &t);
    void set_lemma(const std::wstring &);
    void set_tag(const std::wstring &);
    void set_prob(double);
    void set_distance(double);
    void set_retokenizable(const std::list<word> &);

    bool has_prob() const;
    bool has_distance() const;
    const std::wstring& get_lemma() const;
    const std::wstring& get_tag() const;
    double get_prob() const;
    double get_distance() const;
    bool is_retokenizable() const;
    std::list<word>& get_retokenizable();
    const std::list<word>& get_retokenizable() const;

    const std::list<std::pair<std::wstring,double> > & get_senses() const;
    std::list<std::pair<std::wstring,double> > & get_senses();
    void set_senses(const std::list<std::pair<std::wstring,double> > &);
    // useful for java API
    std::wstring get_senses_string() const;

    // get the largest kbest sequence index the analysis is selected in.
    int max_kbest() const;
    // find out whether the analysis is selected in the tagger k-th best sequence
    bool is_selected(int k=0) const;
    // mark this analysis as selected in k-th best sequence
    void mark_selected(int k=0);
    // unmark this analysis as selected in k-th best sequence
    void unmark_selected(int k=0);
  };
```

# Class <tt>sentence</tt> {#class-sentence}

Words are grouped to form sentences. A <tt>sentence</tt> is basically a list of <tt>word</tt> objects, but it also may contain additional information, such as a parse tree, a dependency tree, or a list of predicates and arguments.

```C++
class sentence : public std::list<word> {

  public:
    sentence();
    ~sentence();
    sentence(const std::list<word>&);
    /// Copy constructor
    sentence(const sentence &);
    /// assignment
    sentence& operator=(const sentence&);
    /// positional access to a word
    const word& operator[](size_t) const;
    word& operator[](size_t);
    /// find out how many kbest sequences the tagger computed
    unsigned int num_kbest() const;
    /// add a word to the sentence
    void push_back(const word &);
    /// rebuild word positional index
    void rebuild_word_index();

    void clear();

    void set_sentence_id(const std::wstring &);
    const std::wstring& get_sentence_id() const;

    void set_is_tagged(bool);
    bool is_tagged() const;

    void set_parse_tree(const parse_tree &, int k=0);
    parse_tree & get_parse_tree(int k=0);
    const parse_tree & get_parse_tree(int k=0) const;
    bool is_parsed() const;

    void set_dep_tree(const dep_tree &, int k=0);
    dep_tree & get_dep_tree(int k=0);
    const dep_tree & get_dep_tree(int k=0) const;
    bool is_dep_parsed() const;

    /// get word list (useful for perl API)
    std::vector<word> get_words() const;
    /// get iterators to word list (useful for perl/java API)
    sentence::iterator words_begin();
    sentence::const_iterator words_begin() const;
    sentence::iterator words_end();
    sentence::const_iterator words_end() const;

    // obtain iterator to a word given its position
    sentence::iterator get_word_iterator(const word &w);
    sentence::const_iterator get_word_iterator(const word &w) const;

    void add_predicate(const predicate &pr);
    /// see if word in given position is a predicate
    bool is_predicate(int p) const;
    /// get predicate number n for word in position p
    int get_predicate_number(int p) const;
    /// get word position for predicate number n
    int get_predicate_position(int n) const;
    /// get predicate for word at position p
    const predicate& get_predicate_by_pos(int n) const;
    /// get predicate number n
    const predicate& get_predicate_by_number(int n) const;
    /// get predicates of the sentence (e.g. to iterate over them)
    const predicates & get_predicates() const;
  };
```

Trees stored in the sentence (either constituency trees or dependency trees) are a STL-like container that offers STL-like iterators to traverse the tree.

Predicates contain the word that heads the predicate in the sentence (typically a verb), plus a vector of arguments (other words in the sentence that play roles in that predicate).

Please check FreeLing Technical Reference Manual to find out details about the API for these classes.

# Classes <tt>paragraph</tt> and <tt>document</tt> {#classes-paragraph-and-document}

Sentences can be grouped in <tt>paragraphs</tt>, and these can be grouped in a <tt>document</tt>

```C++
class paragraph : public std::list<sentence> {
  public:
    paragraph();
    paragraph(const std::list<sentence> &x);
    void set_paragraph_id(const std::wstring &);
    const std::wstring & get_paragraph_id() const;
  };
```

Class <tt>document</tt> is able to contain a sequence of <tt>paragraphs</tt>, each containing several <tt>sentences</tt>, each of which is made of <tt>words</tt> that have different <tt>analysis</tt>.

In addition, a <tt>document</tt> may contain also information about the coreference of different mentions in the text referring to the same entity, and provides methods to access this information.

Please check FreeLing Technical Reference Manual to find out details about the API for class <tt>mention</tt>.

```C++
class document : public std::list<paragraph> {

  public:
    document();
    ~document();

    bool is_parsed() const;
    bool is_dep_parsed() const;

    /// Adds one mention to the doc (the mention should be already 
    /// assigned to  a group of coreferents)
    void add_mention(const mention &m);

    // count number of words in the document
    int get_num_words() const;

    /// Gets the number of coreference groups found
    int get_num_groups() const;
    /// get list of ids of existing groups
    const std::list<int> & get_groups() const;

    /// Gets an iterator pointing to the beginning of the mentions 
    std::vector<mention>::const_iterator begin_mentions() const;
    std::vector<mention>::iterator begin_mentions();
    /// Gets an iterator pointing to the end of the mentions 
    std::vector<mention>::const_iterator end_mentions() const;
    std::vector<mention>::iterator end_mentions();

    /// get reference to i-th mention
    const mention& get_mention(int) const;

    /// Gets all the nodes in a coreference group
    ///std::list<int> get_coref_nodes(int) const;

    /// Gets all the mentions' ids in the ith coreference group found
    std::list<int> get_coref_id_mentions(int) const;

    /// Returns if two nodes are in the same coreference group
    /// bool is_coref(const std::wstring &, const std::wstring &) const;

    const semgraph::semantic_graph & get_semantic_graph() const;
    semgraph::semantic_graph & get_semantic_graph();
  };
```

Finally, the <tt>document</tt> may contain also a semantic graph describing relations between entities and events.

The graph contains instances of <tt>SG_entity</tt> (an entity mentioned in the text, one or more times) and <tt>SG_frame</tt> (an event, relation or action described in the text). Objects of class <tt>SG_frame</tt> contain <tt>SG_argument</tt> instances that describe which entities are involved in that event.

Please check FreeLing Technical Reference Manual to find out details about the API for classes contained in the <tt>semgraph</tt>.

```C++
class semantic_graph {
    public:
      semantic_graph();
      ~semantic_graph();

      std::wstring add_entity(SG_entity &ent);
      std::wstring add_frame(SG_frame &fr);

      const SG_frame & get_frame(const std::wstring &fid) const;
      SG_frame & get_frame(const std::wstring &fid);

      std::wstring get_entity_id_by_mention(const std::wstring &sid,
                                           const std::wstring &wid) const;
      std::wstring get_entity_id_by_lemma(const std::wstring &lemma,
                                         const std::wstring &sens=L"") const;
      SG_entity & get_entity(const std::wstring &eid);
      const SG_entity & get_entity(const std::wstring &eid) const;

      const std::vector<SG_entity> & get_entities() const;
      std::vector<SG_entity> & get_entities();

      const std::vector<SG_frame> & get_frames() const;
      std::vector<SG_frame> & get_frames();

      void add_mention_to_entity(const std::wstring &eid, 
                                const SG_mention &m);
      void add_argument_to_frame(const std::wstring &fid, 
                                const std::wstring &role, 
                                const std::wstring &eid);

      bool is_argument(const std::wstring &eid) const;     
      bool has_arguments(const std::wstring &fid) const;

      bool empty() const;
    };
```

