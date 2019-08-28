# Splitter Module {#splitter-module}

The splitter module receives lists of <tt>word</tt> objects (either produced by the tokenizer or by any other means in the calling application) and buffers them until a sentence boundary is detected. Then, a list of <tt>sentence</tt> objects is returned.

The buffer of the splitter may retain part of the tokens if the given list didn't end with a clear sentence boundary. The caller application can submit further token lists to be added, or request the splitter to flush the buffer.

In order to be thread-safe, the splitter needs to keep different internal buffers for different threads (or for the same thread, if it uses the same splitter to split two different text sources alternatively). Thus, the calling application must open a splitting session to obtain an id, that will identify the internal buffer to use.

In addition, each session will have its own sentence-id counter, so sentences processed in the same session are assigned correlative sentence-ids (starting at 1).

The API for the splitter class is:

```C++
class splitter {
  public:
    /// Constructor. Receives a file with the desired options
    splitter(const std::wstring &cfgfile);

    /// Destructor
    ~splitter();

    /// splitter::session_id is the type to store session ids
    typedef int session_id;

    /// open a splitting session, get session id
    session_id open_session();

    /// close splitting session
    void close_session(session_id ses);

    /// Add given list of words to the buffer, and put complete sentences 
    /// that can be build into ls.
    /// The boolean states if a buffer flush has to be forced (true) or
    /// some words may remain in the buffer (false) if the splitter 
    /// needs to wait to see what is coming next.
    /// Each thread using the same splitter needs to open a new session.
    void split(session_id ses, 
               const std::list<word> &lw, 
               bool flush, 
               std::list<sentence> &ls);

    /// same than previous method, but result sentences are returned.
    std::list<sentence> split(session_id ses, 
                              const std::list<word> &lw, 
                              bool flush);

};
```

## Splitter Options File {#splitter-options-file}

The splitter options file contains four sections: `<General>`, `<SentenceEnd>`, `<SentenceStart>`, and `<Markers>`.

The `<General>` section contains general options for the splitter: Namely, <tt>AllowBetweenMarkers</tt> and <tt>MaxWords</tt> options. The former may take values 1 or 0 (on/off). The later may be any integer. An example of the `<General>` section is:

```XML
<General>
AllowBetweenMarkers 0
MaxWords 0
</General>
```

If <tt>AllowBetweenMarkers</tt> is off (<tt>0</tt>), a sentence split will never be introduced inside a pair of parenthesis-like markers, which is useful to prevent splitting in sentences such as *"I hate --Mary said. Angryly.-- apple pie"*. If this option is on (<tt>1</tt>), sentence splits will be introduced as if they had happened outside the markers.

The value for <tt>MaxWords</tt> states how many words are processed before forcing a sentence split inside parenthesis-like markers (this option is intended to avoid memory fillups in case the markers are not properly closed in the text).  
A value of zero means *Never split, I'll risk to a memory fillup*. This option is less aggressive than unconditionally activating <tt>AllowBetweenMarkers</tt>, since it will introduce a sentence split between markers only after a sentence of length <tt>MaxWords</tt> has been accumulated. Setting <tt>MaxWords</tt> to a large value will prevent memory fillups, while keeping at a minimum the splittings inside markers.

The `<Markers>` section lists the pairs of characters (or character groups) that have to be considered open-close markers. For instance:  
```XML
<Markers>
 " "
 ( )
 { }
 /* */
 </Markers>
```

The `<SentenceEnd>` section lists which characters are considered as possible sentence endings. Each character is followed by a binary value stating whether the character is an unambiguous sentence ending or not. For instance, in the following example, `?` is an unambiguous sentence marker, so a sentence split will be introduced unconditionally after each `?`. The other two characters are not unambiguous, so a sentence split will only be introduced if they are followed by a capitalized word or a sentence start character.

```XML
<SentenceEnd>
 . 0
 ? 1
 ! 0
 </SentenceEnd>
```

The `<SentenceStart>` section lists characters known to appear only at sentence beggining. For instance, open question/exclamation marks in Spanish:

```XML
<SentenceStart>
 ? 
 !
 </SentenceStart>
```
