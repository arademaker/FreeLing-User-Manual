
# Approximate search dictionary {#approximate-search-dictionary}

This class wraps a <tt>libfoma</tt> FSM and allows fast retrieval of similar words via string edit distance based search.

The API of the class is the following:

```C++
class foma_FSM {

  public:
    typedef enum {FSM_DICC,FSM_COMPOUNDS} FSM_Type;

    /// build automaton from file
    foma_FSM(const std::wstring &, 
             FSM_Type type=FSM_DICC, 
             const std::wstring &mcost=L""); 
    /// clear 
    ~foma_FSM();

    /// Use automata to obtain closest matches to given form, 
    /// and add them to given list.
    void get_similar_words(const std::wstring &, 
                           std::list<std::pair<std::wstring,int> > &) const;    
    /// set maximum edit distance of desired results
    void set_cutoff_threshold(int);
    /// set maximum number of desired results
    void set_num_matches(int);
    /// Set cost for basic SED operations (insert, delete, substitute)
    void set_basic_operation_cost(int);
    /// Set cost for a particular SED operation (replace "in" with "out")
    void set_operation_cost(const std::wstring &in, 
                            const std::wstring &out, 
                            int cost);
  };
```

The constructor of the module requests one parameter stating the file to load, second optional parameter stating whether the automata must recognize just the words in the given dictionary file, or it must recognize compounds of these words (that is, the language _L_(_L_ +)). The third parameter -also optional- is a file with the cost matrix for SED operations. If the cost matrix is not given, all operations default to a cost of 1 (or to the value set with the method `set_basic_operation_cost`).

The automata file may have extension `.src` or `.bin`. If the extension is `.src`, the file is intepreted as a text file with one word per line. The FSM is built to recognize the vocabulary contained in the file.

If the extension is `.bin`, the file is intepreted as a binary <tt>libfoma</tt> FSM. To compile such a binary file, FOMA command line front-end must be used. The front-end is not included in FreeLing. You will need to install FOMA if you want to create binary FSM files. See [FOMA documentation](http://code.google.com/p/foma) for details.

A cost matrix for SED operations may be specified only for text FSMs (i.e., for `.src` files). To use a cost matrix with a `.bin` file, you need to compile it into the automata using FOMA front-end.

The format of the cost matrix must comply with FOMA formats. See FOMA documentation, or examples provided in `data/common/alternatives` in FreeLing tarball.

The method `get_similar_words` will receive a string and return a list of entries in the FSM vocabulary sorted by string edit distance to the input string.
