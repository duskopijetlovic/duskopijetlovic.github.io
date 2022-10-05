---
layout: post
title: "Using Graphviz Clusters"
date: 2022-09-24 09:13:07 -0700 
categories: howto diagram graph graphviz plaintext text tex latex visualization sysadmin documentation
---

Host OS: FreeBSD 13, Shell: csh    

```
% cat backupmap.dot
/*
   Command to create the graph (when splines = "line";): 
       dot -Tpng backupmap.dot -o backupmap.png

   Command to create the graph (when splines = "ortho"; in the dot file): 
       dot -Gsplines=none backupmap.dot | neato -n -Gsplines=ortho -Tpng -o backupmap.png
   ---> https://stackoverflow.com/questions/7922960/block-diagram-layout-with-dot-graphviz

   To view the graph:
   Install image viewer and cataloguer; for example:
       xv backupmap.png &
   Or: 
       feh backupmap.png &
*/

/*
  From:
    https://stackoverflow.com/questions/7586376/graphviz-subgraph-doesnt-get-visualized

  From the graphiz documentation, section "Subgraphs and Clusters":

  The third role for subgraphs directly involves how the graph will be laid 
  out by certain layout engines.  

  From the graphviz documentation:
    https://graphviz.org/docs/attrs/cluster/

  If the name of the subgraph begins with "cluster", Graphviz notes the 
  subgraph as a special cluster subgraph. 

  Alternatively, you can use
    cluster=true;
  within a cluster.
*/

digraph backupMap {
  /* 
     http://graphs.grevian.org/reference
     Used to influence the 'spring' used in the layout. 
     Can be used to push nodes further apart, which is especially useful 
     for twopi and sfdp layouts
  */
  K = 0.6;
  
  /*
     Graphviz - FaqClusterEdge - How can I create edges between cluster boxes?
     http://www.graphviz.org/content/FaqClusterEdge
  */ 
  compound = true; 

  splines = "line"; // Force edges to be straight, no curves or angles
  //splines = "ortho"; 
  rankdir = "LR";   // NOTE: rankdir can be used only once
  //rankdir = "TB";
  graph [newrank = true]; 
  // To get the list of fonts:  fc-list
  node[fontname = "Hermit-Bold", width = 1.5, height = 0.45, fontsize=9];
  nodesep = 0.14;

  /*  Subgraph Clusters
  
      Graphviz cluster alignment
        https://stackoverflow.com/questions/67295008/graphviz-cluster-alignment
  */

  subgraph clusterMain
  {
    style = "dashed"; 
    color = "#625a5a";
    //peripheries = 0;  // To remove border around the cluster

    //label = "MAIN CLUSTER";
    //graph[rankdir = "LR"];
    node [shape = box, style = filled, color = black, fillcolor = "#91cf60"];

    node [group = vert];
    a[group = g1, label = "Servers"];
    nfsServer [group = g1, label = "NFS Servers"]; 
    b[group = g1, label = "Backup Destinations"];

    // Added minlen in order to push the three "Backup Destination" clusters further away
    // NOTE:  This is the first  minlen; there's another one further below
    a -> nfsServer [minlen = 2.7, style = invis]; 
    nfsServer -> b [style = invis];
  }

  subgraph clusterA
  {
    color = "#625a5a";
    node [shape = box, style = filled, color = black, fillcolor = "#fee08b"];
    peripheries = 0;  // To remove border around the cluster

    a15[label = "redwood"];
    a14[label = "chestnut"];
    a13[label = "neon"];
    a12[label = "www"];
    a11[label = "xenon"];
    a10[label = "mail"];
    a9[label  = "mailx"];
    a8[label  = "groups"];
    a7[label  = "titanium"];
    a6[label  = "chemapps"];
    a5[label  = "wapps"];
    a4[label  = "www5"];
    a3[label  = "abacus"];
    a2[label  = "kvmhost3"];
    a1[label  = "ost"];
  }

  {rank = same a -> {a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 a13 a14 a15} [style = invis] };
  {rank = same b -> {LenovoDS2200 dcds1821 zfs} [ style = invis ] };  


  subgraph clusterBackupToLenovoSANds2200
  {
    //label = "Backup Destination 1";
    label = "                    ";

    node [fillcolor = "#F5F5F5", style = filled, shape = "rectangle"]; 

    /*
      Group these two nodes - to keep the edges straight.

      From Graphviz documentation:  Attributes - group:

        Name for a group of nodes, for bundling edges avoiding crossings.

        If the end points of an edge belong to the same group, i.e., have the 
        same group attribute, parameters are set to avoid crossings and keep 
        the edges straight.
    */
    kvmhost2 [group = gLenovoSAN, height = 0.10];
    LenovoDS2200 [group = gLenovoSAN, penwidth=5.0, shape = "cylinder", label = "Lenovo DS2200\n\nSAN Array"]; 

    kvmhost2 -> LenovoDS2200 [label = "iSCSI"]; 
  }


  {rank = same kvmhost2 -> legend [style = invis] };


  subgraph clusterBackupToDcDs1821NAS
  {
    //label = "Backup Destination 2";
    label = "                   ";

    node [fillcolor = "#F5F5F5", style = filled, shape = "rectangle"];
    dummy1821 [style = invis];
    dcds1821 [penwidth = 5.0, shape = "cylinder", label = "dc-ds1821\n\nSynology NAS"];

    // To force the subgraph to be similar size to the other two Backup Destinations subgraphs
    dummy1821 -> dcds1821 [style = invis]; 
  }

  subgraph clusterBackupToKrypton
  {
    //label = "Backup Destination 3";
    label = "                    ";

    node [fillcolor="#F5F5F5", style=filled, shape="rectangle"]; 

    krypton [group = gKrypton, height = 0.10];
    zfs [group = gKrypton, penwidth = 5.0, shape = "cylinder", label = "napp-it Appliance\nZFS\nOpenIndiana"];

    krypton -> zfs [label = "iSCSI"];
  } 

  subgraph clusterLegend
  {
    dLC [ style = invis ];
    peripheries = 0;  // To remove border around the cluster

    legend
    [shape=none, margin=0, label=
      <
        <table border="0" cellborder="1" cellspacing="0" cellpadding="4">
          <tr><td colspan="2">Legend</td></tr>
          <tr><td><font color="red">red</font></td><td><font color="red">Nightly rsync NFS</font></td></tr>
          <tr><td><font color="green">green</font></td><td><font color="green">tar via NFS</font></td></tr>
          <tr><td><font color="blue">blue</font></td><td><font color="blue">Nightly rsync</font></td></tr>
          <tr><td>D</td><td>Databases</td></tr>
          <tr><td>W</td><td>/web or /www or /var/www dir</td></tr>
          <tr><td>H</td><td>/home dir</td></tr>
          <tr><td>G</td><td>/global dir</td></tr>
          <tr><td>E</td><td>/etc, /opt, /root, /usr, /var directories</td></tr>
        </table>
      >];

      dLC -> legend [style = invis];
  }

  edge [fontsize=9.0];

  a1:e  -> kvmhost2 [taillabel="D, W", color="green"];                  // ost
  a2:e  -> kvmhost2 [taillabel="E", color="red"];                       // kvmhost3
  a3:e  -> kvmhost2 [taillabel="G, H, E", color="red"];                 // abacus 
  a4:e  -> kvmhost2 [taillabel="D, W", color="green"];                  // www5
  a5:e  -> kvmhost2 [taillabel="D, W", color="red"];                    // wapps
  a6:e  -> kvmhost2 [taillabel="D, W", color="red"];                    // chemapps
  // Added minlen in order to push the three "Backup Destination" clusters further away
  // NOTE:  This is the second minlen; the first one is around 200 lines above
  a7:e  -> kvmhost2 [taillabel="E, W, H", minlen = 2.7, color="green"]; // titanium 
  a8:e  -> kvmhost2 [taillabel="H, D", color="red"];                    // groups
  a9:n  -> kvmhost2 [taillabel="H", color="red"];                       // mailx
  a9:e  -> zfs      [taillabel="H", color="blue"];                      // mailx
  a9    -> dcds1821 [taillabel="H, E", color="blue"];                   // mailx
  a10:e -> kvmhost2 [taillabel="H", color="red"];                       // mail
  a11:e -> kvmhost2 [taillabel="H, D, W", color="green"];               // xenon 
  a12:e -> kvmhost2 [taillabel="D, W", color="green"];                  // www
  a13:e -> zfs [taillabel="D, W", color="green"];                       // neon
  a14:e -> dcds1821 [taillabel="E", color="blue"];                      // chestnut
  a15:e -> dcds1821 [taillabel="E", color="blue"];                      // redwood

/*
   Graphiz FAQ
     https://graphviz.org/faq/#FaqGraphLabel
   Q: How can I set a graph or cluster label without its propagating to all sub-clusters?
   A: Set the label at the end of the graph (before the closing brace), 
      after all its contents have been defined. (We admit it seems desirable 
      to define some special syntax for non-inherited attribute settings.)
*/
  label = "Backup Map\nUpdated on: Sep 24, 2022";

}
```


```
% dot -Tpng backupmap.dot -o backupmap.png
```

```
% xv backupmap.png
```

![Displaying a backup diagram png image created by Grapvhiz](/assets/img/backupmap.png "Displaying a backup diagram png image created by Grapvhiz")
