
/<DecompositionRules>/ {
  inside=1; 
  delete field;
  delete vals;
  next;
}

/<\/DecompositionRules>/ {
  inside=0;
  next;
}

{
   if (inside) {
     print "\n### Part of Speech: `"$3"`"

     print "| Position | Atribute | Values |";
     print "|:----     |:----     |:----   |";

     print "| 0        | category | **"$1"**:_"$3"_ |";

     for (i=4; i<=NF; i++) {
        split($i,a,"/");
        printf "| %d | %s | ",i-3, a[1];
        n = split(a[2],b,";")
        v = "";
        for (j=1; j<n; j++) {
            split(b[j],c,":");
            if (c[2]!="0")
                v = v "  **"c[1]"**:_"c[2]"_; ";
        }
        
        split(b[n],c,":");
        if (c[2]!="0")
            v = v "  **"c[1]"**:_"c[2]"_";
        
        if (v=="") v="_Not used_";
        printf "%s|\n",v;
     }    
   }
}
