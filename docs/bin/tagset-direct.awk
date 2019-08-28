{
    n=split($3,t,"|");

    if (t[1]!=ant) {
        split(t[1],p,"=");
        print "\n### Part of Speech: `"p[2]"`"
        print "| Tag  | Attributes |";
        print "|:---- |:----       |";
    }

    printf "| %s |",$1;
    for (i=1; i<n; i++) {
        split(t[i],p,"=");
        printf " **%s**:_%s_; ",p[1],p[2];        
    }
    split(t[n],p,"=");
    printf "  **%s**:_%s_",p[1],p[2];
    printf "|\n";

    ant=t[1];

}