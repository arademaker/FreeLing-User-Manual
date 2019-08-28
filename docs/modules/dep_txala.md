
# Rule-based Dependency Parser Module {#rule-based-dependency-parser-module}

The Txala dependency parser [\[ACM05\]](../references.md) gets constituency parsed sentences -that is, `sentence` objects which have been enriched with a `parse_tree` by the `chart_parser` (or by any other means).  The input parsing may be shallow. The dependency parser will complete the parse tree if needed, convert it to a dependency tree, and assign a syntactic function to each edge in the dependency tree.

```C++
class dep_txala : public dependency_parser {
 public:   
   /// constructor
   dep_txala(const std::string &cfgfile, const std::string &start);

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

The constructor receives two strings: the name of the file containging the dependency rules to be used, and the start symbol of the grammar used by the `chart_parser` to parse the sentence.

The dependency parser works in three stages:
*   At the first stage, the `<GRPAR>` rules are used to complete the shallow parsing produced by the chart into a complete parsing tree. The rules are applied to a pair of adjacent chunks. At each step, the selected pair is fused in a single chunk. The process stops when only one chunk remains.
*   The next step is an automatic conversion of the complete parse tree to a dependency tree. Since the parsing grammar encodes information about the head of each rule, the conversion is straighforward.
*   The last step is the labeling. Each edge in the dependeny tree is labeled with a syntactic function, using the `<GRLAB>` rules.

The syntax and semantics of `<GRPAR>` and `<GRLAB>` rules are described below.


## Dependency Parsing Rule File {#dependency-parsing-rule-file}

The dependency rules file contains a set of rules to perform dependency parsing.

The file consists of five sections: sections: `<GRPAR>`, `<GRLAB>`, `<SEMDB>`, `<CLASS>`, and `<PAIRS>`.

### Parse-tree completion rules {#parse-tree-completion-rules}

Section `<GRPAR>` contains rules to complete the partial parsing provided by the chart parser. The tree is completed by combining chunk pairs as stated by the rules. Rules are applied from highest priority (lower values) to lowest priority (higher values), and left-to right. That is, the pair of adjacent chunks matching the most prioritary rule is found, and the rule is applied, joining both chunks in one. The process is repeated until only one chunk is left.

The rules can be enabled/disabled via the activation of global flags. Each rule may be stated to be enabled only if certain flags are on. If none of its enabling flags are on, the rule is not applied. Each rule may also state which flags have to be toggled on/off after its application, thus enabling/disabling other rule subsets.

Each line in section `<GRPAR>` contains a rule, with the format:  
`priority flags context (lchunk,rchunk) pair-constraints operation op-params flag-ops`

where:
*   `priority` is a number stating the priority of a rule (the lower the number, the higher the priority).
*   `flags` is a list of strings separated by vertical bars (`|`). Each string is the name of a flag that will cause the rule to be enabled. If this field is `-`, the rule will be always enabled.
*   `context` is a context limiting the application of the rule only to chunk pairs that are surrounded by the appropriate context. A dash (`-`) means no restrictions, and the rule is applied to any matching chunk pair.
*   `(lchunk,rchunk)` are the labels of the adjacent pair of chunks the rule may be applied to. The labels are either assigned by the chunk parser, or by a `RELABEL` operation on some other completion rule. The pair must be enclosed in parenthesis, separated by a comma, and contain NO whitespaces.

    The chunk labels may be suffixed with one extra condition of the form: `(form)`, `<lemma>`, `[class]`, or `{PoS_regex}`.

    For instance,

| The label: | Would match: |
    |:--- |: --- |
    | `np`       | any chunk labeled `np` by the chunker |
    | `np(cats)` | any chunk labeled `np` by the chunker with a head word with form `cats` |
    | `np<cat>`  | any chunk labeled `np` by the chunker with a head word with lemma `cat` |
    | `np[animal]` | any chunk labeled `np` by the chunker with a head word with a lemma in `animal` category (see `CLASS` section below)|
    | `np{^N.M[PS]}` | any chunk labeled `np` by the chunker with a head word with a PoS tag matching the regular expression `^N.M[PS]`  |
  

*   `pair-constraits` expresses a constraint that must be satisfied by the pair of target chunks `(lchunk,rchunk)`. If no constraints are required, this field must be a dash (`-`). The format of the constraint is `pairclass::(value1,value2)`, where:
    *   `pairclass` is the name of a pair class defined in the `<PAIRS>` section (see below).
    *   `value1` and `value2` are the two values that must belong to the pair class.

        Each `value` specifies whether the value is to be extracted from `lchunk` (`L`) or `rchunk` (`R`), the path to or a node below them (if target is not the root), and the attribute to extract.

        For instance, `L.lemma` specifies the lemma of the head word of `lchunk`. `R:sn.pos` specifies the PoS tag of the head word of a node with label `sn` located under `rchunk`. `R:sp:sn.semfile` specifies the semantic file of the head word of a node with label `sn` located under a node with label `sp` located under `rchunk`.

        Valid attributes are: `lemma`, `pos`, `semfile`, `tonto`, `synon`, `asynon`. Their meaning is the same than for dependency labeling rules, and is described below.

*   `operation` is the way in which `lchunk` and `rchunk` nodes are to be combined (see below).

*   `op-params` has two possible meanings, depending on the `operation` field: `top_left` and `top_right` operations must be followed by the literal `RELABEL` plus the new label(s) to assign to the chunks. Other operations must be followed by the literal `MATCHING` plus the label to be matched.

    For `top_left` and `top_right` operations the labels following the keyword `RELABEL` state the labels with which each chunk in the pair will be relabelled, in the format `label1:label2`. If specified, `label1` will be the new label for the left chunk, and `label2` the one for the right chunk. A dash ( `-`) means no relabelling. In none of both chunks is to be relabelled, `-` may be used instead of `-:-`. For example, the rule:
    `20 - - (np,pp<of>) top_left RELABEL np-of:- -`   
    will hang the `pp` chunk as a daughter of the left chunk in the pair (i.e. `np`), then relabel the `np` to `np-of`, and leave the label for the `pp` unchanged.

    For `last_left`, `last_right` and `cover_last_left` operations, the label following the keyword `MATCHING` states the label that a node must have in order to be considered a valid `last` and get the subtree as a new child. This label may carry the same modifying suffixes than the chunk labels. If no node with this label is found in the tree, the rule is not applied. For example, the rule:   
    `20 - - (vp,pp<of>) last_left MATCHING np -`    
    will hang the `pp` chunk as a daughter of the last subtree labeled `np` found inside the `vp` chunk.

    *   The last field `flag-ops` is a space-separated list of flags to be toggled on/off. The list may be empty (meaning that the rule doesn't change the status of any flag). If a flag name is preceded by a `+`, it will be toggled on. If the leading symbol is a `-`, it will be toggled off.

For instance, the rule:
```
20 - - (np,pp<of>) top_left RELABEL - -
```

states that if two subtrees labelled `np` and `pp` are found contiguous in the partial tree, and the second head word has lemma `of`, then the later (rightmost) is added as a new child of the former (leftmost), whatever the context is, without need of any special flag active, performing no relabelling of the new tree root, and without activating or deactivating any flags.

The supported tree-building operations are the following:

*   `top_left`: The right subtree is added as a daughter of the left subtree. The root of the new tree is the root of the left subtree. If a `label` value other than `-` is specified, the root is relabelled with that string.
*   `last_left`: The right subtree is added as a daughter of the last node inside the left subtree matching `label` value (or to the root if none is found). The root of the new tree is the root of the left subtree.
*   `top_right`: The left subtree is added as a new daughter of the right subtree. The root of the new tree is the root of the right subtree. If a `label` value other than `-` is specified, the root is relabelled with that string.
*   `last_right`: The left subtree is added as a daughter of the last node inside the right subtree matching `label` value (or to the root if none is found). The root of the new tree is the root of the right subtree.
*   `cover_last_left`: The left subtree (_s_) takes the position of the last node (_x_) inside the right subtree matching `label` value. The node _x_ is hanged as new child of _s_. The root of the new tree is the root of the right subtree.

The context may be specified as a sequence of chunk labels, separated by underscores `_`. One of the chunk labels must be `$$`, and refers to the pair of chunks which the rule is being applied to.

For instance, the rule:
```
20 - $$_vp (np,pp<of>) top_left RELABEL -
```
would add the right chunk in the pair (`pp<of>`) under the left one (`np`) only if the chunk immediate to the right of the pair is labeled `vp`.

Other admitted labels in the context are: `?` (matching exactly one chunk, with any label), `*` (matching zero or more chunks with any label), and `OUT` (matching a sentence boundary).

For instance the context `np_$$_*_vp_?_OUT` would match a sentence in which the focus pair of chunks is immediately after an `np`, and the second-to-last chunk in the sentence is labeled `vp`.

Context conditions can be globally negated preceding them with an exclamation mark (`!`). E.g. `!np_$$_*_vp` would cause the rule to be applied only if that particular context is not satisfied.

Context condition components may also be individually negated preceding them with the symbol `~`. E.g. the rule `np_$$_~vp` would be satisfied if the preceding chunk is labeled `np` and the following chunk has any label but `vp`.

Enabling flags may be defined and used at the grammarian's will. For instance, the rule:
```
20 INIT|PH1 $_vp (np,pp<of>) last_left MATCHING nphrase[animal] +PH2 -INIT -PH1
```
Will be applied if either `INIT` or `PH1` flags are on, the chunk pair is a `np` followed by a `pp` with head lemma `of`, and the context (one `vp` chunk following the pair) is satisfied. Then, the deepest rightmost node matching the label `nphrase[animal]` will be sought in the left chunk, and the right chunk will be linked as one of its children. If no such node is found, the rule will not be applied.

After applying the rule, the flag `PH2` will be toggled on, and the flags `INIT` and `PH1` will be toggled off.

The only predefined flag is `INIT`, which is toggled on when the parsing starts. The grammarian can define any alphanumerical string as a flag, simply toggling it on in some rule.


### Dependency function labeling rules {#dependency-function-labeling-rules}

Labelling rules defined in section `<GRLAB>` are applied once the tree has been completed and converted to a dependency tree. 
For each edge in the tree, the first matching rule is located and applied.

Section `<GRLAB>` contains two kind of lines.

The first kind are the lines defining `UNIQUE` labels, which have the format:
```
UNIQUE label1 label2 label3 ...
```
You can specify many `UNIQUE` lines, each with one or more labels. The effect is the same than having all of them in a single line, and the order is not relevant.

Labels in `UNIQUE` lists will be assigned only once per head. That is, if a head has a daugther with a dependency already labeled as `label1`, rules assigning this label will be ignored for all other daugthers of the same head. (e.g. if a verb has got a `subject` label for one of its dependencies, no other dependency will get that label, even if it meets the conditions to do so).

The second kind of lines state the rules to label the dependences extracted from the full parse tree build with the rules in previous section:

Each line contains a rule, with the format:
```
ancestor-label dependence-label condition1 condition2 ...
```
where:
*   `ancestor-label` is the label of the node which is head of the dependence.
*   `dependence-label` is the label to be assigned to the dependence
*   `condition` is a list of conditions that the dependence has to match to satisfy the rule.

Each `condition` has one of the forms:
```
node.attribute = value
node.attribute != value
```
Where `node` is a string describing a node on which the `attribute` has to be checked. The `value` is a string to be matched, or a set of strings (separated by `|`). The strings can be right-wildcarded (e.g. `np*` is allowed, but not `n*p`). For the `pos` attribute, `value` can be any valid regular expression.

The `node` expresses a path to locate the node to be checked. The path must start with `p` (parent node) or `d` (descendant node), and may be followed by a colon-separated list of labels. For instance `p:sn:n` refers to the first node labeled `n` found under a node labeled `sn` which is under the dependency parent `p`.

The `node` may be also `As` (_All siblings_) or `Es` (_Exists sibling_) which will check the list of all children of the ancestor (`p`), excluding the focus daughter (`d`). `As` and `Es` may be followed by a path, just like `p` and `d`. For instance, `Es:sn:n` will check for a sibling with that path, and `As:sn:n` will check that all siblings have that path.

The `node` may be also a pair of the form `[node1.attribute,node2.attribute]` where `node1` and `node2` can be a node path (e.g. `p:sn:n`, `p`, etc) but not `As`,`Es`, or another pair. In this case, the attributes for `node1` and `node2` can only be one of `label`, `lemma`, or `pos`. Finally, the attribute for such a pair node can be only `pairclass`.

Possible <tt>attribute</tt> to be used:
*   `label`: chunk label (or PoS tag) of the node.
*   `side`: (left or right) position of the specified node with respect to the other. Only valid for `p` and `d`.
*   `lemma`: lemma of the node head word.
*   `pos`: PoS tag of the node head word
*   `class`: word class (see below) of lemma of the node head word.
*   `tonto`: EWN Top Ontology properties of the node head word.
*   `semfile`: WN semantic file of the node head word.
*   `synon`: Synonym lemmas of the node head word (according to WN).
*   `asynon`: Synonym lemmas of the node head word ancestors (according to WN).
*   `pairclass`: Only applicable to pair nodes. Check whether the pair is in any of specified classes.

Note that since no disambiguation is required, the attributes dealing with semantic properties will be satisfied if any of the word senses matches the condition.

For instance, the rule:
```
verb-phr    subj    d.label=np*      d.side=left
```
states that if a `verb-phr` node has a daughter to its left, with a label starting by `np`, this dependence is to be labeled as `subj`.

Similarly, the rule:
```
verb-phr    obj    d.label=np*  d:sn.tonto=Edible  p.lemma=eat|gulp
```
states that if a `verb-phr` node has `eat` or `gulp` as lemma, and a descendant with a label starting by `np` and containing a daughter labeled `sn` that has `Edible` property in EWN Top ontology, this dependence is to be labeled as `obj`.

Another example:
```
verb-phr    iobj   d.label=pp* d.lemma=to|for  Es.label=np*
```
states that if a `verb-phr` has a descendant with a label starting by `pp` (prepositional phrase) and lemma `to` or `for`, and there is another child of the same parent which is a noun phrase (`np*`), this dependence is to be labeled as `iobj`.

Yet another:
```
verb-phr    dobj   d.label=pp* d.lemma=to|for  As.label!=np*
```
states that if a `verb-phr` has a descendant with a label starting by `pp` (prepositional phrase) and lemma `to` or `for`, and all the other children of the same parent are not noun phrases (`np*`), this dependence is to be labeled as `dobj`.

And some examples for `pairclass`:
```
verb-phr dobj d.label=noun-phr* d.side=right [p.lemma,d.lemma].pairclass=direct
verb-phr loc d.label=pp* d.lemma=in|at d.side=right [p.lemma,d:noun-phr.lemma].pairclass=location
```
First rule above states that a `noun-phr` daughter under a `verb-phr` parent will be labeled as `dobj` if it is to the right of its parent, and the pair formed by their lemmas is found in the `direct` pair class (which should be defined in section `<PAIRS>` as described below).

The second rule states that a `pp` daughter under a `verb-phr` parent will be labeled as `loc` if it is to the right of its parent, the preposition heading the `pp` is `in` or `at`, and the pair formed by the verb lemma and the noun heading the noun phrase inside the `pp` is found in the `location` pair class (which should be defined in section `<PAIRS>` as described below).

### Semantic database location {#semantic-database-location}

Section `<SEMDB>` is only necessary if the dependency labeling rules in section `<GRLAB>` use conditions on semantic values (that is, any of `tonto`, `semfile`, `synon`, or `asynon`). Since it is needed by `<GRLAB>` rules, section `<SEMDB>` must be defined before section `<GRLAB>`. The section must contain a single line specifying a configuration file for a semanticDB object. The filename may be absolute or relative to the location of the dependency rules file.
```XML
<SEMDB>
../semdb.dat
</SEMDB>
```
The configuration file must follow the format described in section [Semantic Database](semdb.md).

### Class definitions {#class-definitions}

Section `<CLASS>` contains class definitions which may be used as attributes in the dependency labelling rules.

Each line contains a class assignation for a lemma, with two possible formats:
```
class-name  lemma      comments
class-name  "filename"   comments
```

For instance, the following lines assign to the class `mov` the four listed verbs, and to the class `animal` all lemmas found in `animals.dat` file. In the later case, if the file name is not an absolute path, it is interpreted as a relative path based at the location of the rule file.

Anything to the right of the second field is considered a comment and ignored.
```XML
<CLASS>
mov     go      %%prep= to,towards  (note that "%%" is not required for comments)
mov     come    %%prep= from        (anything after 2nd field is ignored)
mov     walk    %%prep= through
mov     run     %%prep= to,towards   D.Obj.

animal "animals.dat"
</CLASS>
```

### Pair-class definitions {#pair-class-definitions}

Section `<PAIRS>` contains class definitions of compatible pairs. They can be used as attributes in the tree-completing rules.

Each line contains a class assignation for a pair, with two possible formats:
```
class-name  element1 element2
class-name  "filename"
```

For instance, the following lines assign to the class `material` the two first pairs, to the class `location` the third and fourth pair, and to class `food"` all pairs found in `food.dat` file. In the later case, if the file name is not an absolute path, it is interpreted as a relative path based at the location of the rule file. The contents of the file must be a list of pairs (one per line).

No comments are allowed in the same line than a pair.
```XML
<PAIRS>
material   table wood
material   knife steel
location   tree forest
location   car road

food    "food.dat"
</PAIRS>
```

These pair classes may be used by tree-completion rules to set constraints to check whether two chunks must be joined or not, and by labeling rules to check whether a head and its dependant have a certain type of relation.
