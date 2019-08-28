# Chart Parser Module {#chart-parser-module}

The chart parser enriches each `sentence` object with a `parse_tree` object, whose leaves have a link to the sentence words.

The API of the parser is:

```C++
class chart_parser {
 public:
   /// Constructor
   chart_parser(const std::string &cfgfile);

   /// Get the start symbol of the grammar
   std::string get_start_symbol() const;

   /// analyze given sentence.
   void analyze(sentence &s) const;

   /// analyze given sentences.
   void analyze(std::list<sentence> &ls) const;

   /// return analyzed copy of given sentence
   sentence analyze(const sentence &s) const;

   /// return analyzed copy of given sentences
   std::list<sentence> analyze(const std::list<sentence> &ls) const;
};
```

The constructor receives a file with the CFG grammar to be used by the parser. See below for details.

The method `get_start_symbol` returns the initial symbol of the grammar, and is needed by the [dependency parser](dep_txala.md).

## Shallow Parser CFG file {#shallow-parser-cfg-file}

This file contains a CFG grammar for the chart parser, and some directives to control which chart edges are selected to build the final tree. Comments may be introduced in the file, starting with ``%'', the comment will finish at the end of the line.

Grammar rules have the form: 
```
x ==> y, A, B.
```

That is, the head of the rule is a non-terminal specified at the left hand side of the arrow symbol. The body of the rule is a sequence of terminals and nonterminals separated with commas and ended with a dot.

Empty rules are not allowed, since they dramatically slow chart parsers. Nevertheless, any grammar may be written without empty rules (assuming you are not going to accept empty sentences).

Rules with the same head may be or-ed using the bar symbol, as in:    
```
x ==> A, y | B, C.
```

The head component for the rule maybe specified prefixing it with a plus (+) sign, e.g.:   
```
nounphrase ==> DT, ADJ, +N, prepphrase.
```
If the head is not specified, the first symbol on the right hand side is assumed to be the head. The head marks are not used in the chart parsing module, but are necessary for later dependency tree building.

The grammar is case-sensitive, so make sure to write your terminals (PoS tags) exactly as they are output by the tagger. Also, make sure that you capitalize your non-terminals in the same way everywhere they appear.

Terminals are PoS tags, but some variations are allowed for flexibility:
*   Plain tag: A terminal may be a plain complete PoS tag, e.g. `VMIP3S0`
*   Wildcarding: A terminal may be a PoS tag prefix, right-wilcarded, e.g. `VMI*`, `VMIP*`.
*   Specifying lemma: A terminal may be a PoS tag (or a wilcarded prefix) with a lemma enclosed in angle brackets, e.g `VMIP3S0<comer>`, `VMI*<comer>` will match only words with those tag/prefix and lemma.
*   Specifying form: A terminal may be a PoS tag (or a wilcarded prefix) with a form enclosed in parenthesis, e.g `VMIP3S0(comió)`, `VMI*(comió)` will match only words with those tag/prefix and form.
*   If a double-quoted string is given inside the angle brackets or parenthesis (e.g. `VMI*("myforms.dat")` or `VMIP3S0<"mylemmas.dat">`) it is interpreted as a file name, and the terminal will match any word form (or lemma) found in that file. If the file name is not an absolute path, it is interpreted as a relative path based at the location of the grammar file.

The grammar file may contain also some directives to help the parser decide which chart edges must be selected to build the tree. Directive commands start with the directive name (always prefixed with `@`), followed by one or more non-terminal symbols, separated with spaces. The list must end with a dot.
 Available directives are: 
*   `@NOTOP`: Non-terminal symbols listed under this directive will not be considered as valid tree roots, even if they cover the complete sentence.
*   `@START`: Specify which is the start symbol of the grammar. Exactly one non-terminal must be specified under this directive. The parser will attempt to build a tree with this symbol as a root. If the result of the parsing is not a complete tree, or no valid root nodes are found, a fictitious root node is created with this label, and all created trees are attached to it.
*   `@FLAT`: Subtrees for non-terminal symbols specified in this list are flattened when the symbol is recursive. Only the highest occurrence appears in the final parse tree.
*   @HIDDEN: Non-teminal symbols specified under this directive will not appear in the final parse tree (their descendant nodes will be attached to their parent).
*   @PRIOR: lists of non-terminal symbols in decreasing priority order (the later in the list, the lower priority). When a chart top cell can be covered with two different non-terminals, the one with highest priority is chosen. This has no effect on non-top cells (in fact, if you want that, your grammar is probably ambiguous and you should rethink it...)
