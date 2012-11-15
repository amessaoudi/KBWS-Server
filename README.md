# Keio Bioinformatics Web Services (server side) (version 1.0.1)

All rights reserved. Copyright © 2012 by OSHITA Kazuki

## License
This Service is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either or version 2 of the License. See also [GNU General Public License Version 2][GPL].

## About
Keio Bioinformatics Web Service (KBWS) is an EMBASSY (EMBOSS associated software) package for accessing popular bioinformatics web services. As an EMBOSS package, KBWS can be accessed from a number of graphical user interfaces, including EMBOSS Explorer, JEMBOSS, and wEMBOSS.

SOAP interface provides language-independent access to 42 bioinformatics analysis programs. The WSDL file contains descriptions for all available programs in a single file, and can be readily loaded in Taverna 2 workbench to integrate with other services to construct workflows. [Example workflows](http://www.myexperiment.org/workflows/1477.html) are available at the [myExperiment](http://www.myexperiment.org) website.

REST interface provides RESTful URL-based access to all analysis programs of KBWS. Here all anallysis resource can be accessed through HTTP GET/POST request.

## Project page
[http://www.g-language.org/kbws/](http://www.g-language.org/kbws/)

## WSDL file (SOAP)
  - RPC/Encoded : [http://soap.g-language.org/kbws.wsdl](http://soap.g-language.org/kbws.wsdl)
  - Document/Literal : [http://soap.g-language.org/kbws_dl.wsdl](http://soap.g-language.org/kbws_dl.wsdl)

## Endpoint (REST)
  - [http://soap.g-language.org/kbws/rest/](http://soap.g-language.org/kbws/rest/)

## List of available processes
- [BioCatalogue web site](http://www.biocatalogue.org/services/2623-glangsoapservice_651637#overview)
- [Project page](http://www.g-language.org/kbws/#block-list)
  - available services, categories, documents, original services, references and quick starts (link to EMBOSS Explorer)

## Publication
"KBWS: an EMBOSS associated package for accessing bioinformatics web services", Oshita K, Arakawa K, Tomita M, *Source Code Biol. Med.*, 2011 , 6, 8 ([PubMed](http://www.ncbi.nlm.nih.gov/pubmed/21529350)).

## Requirements
- System
  - perl
    - version 5.8.8 or later
  - [centroidfold](http://www.ncrna.org/software/centroidfold)

- Perl module
  - SOAP::Lite
    -  version 0.712 or later
  - LWP::UserAgent
  - LWP::Simple
  - HTML::Form
  - JSON
  - MIME::Base64 (for Document/Literal access)
  - BioPerl (for BLAST service)
    - Bio::Tools::Run::RemoteBlast
    - Bio::SearchIO

## Usage
In this service, all methods require fasta format sequence data named as 'in0'.

### SOAP interface
Users are able to connect to this service via SOAP 1.1 (RPC/Encoded and Document/Literal).

#### Sample scripts
- [Sample codes for accessing via SOAP interface](http://www.g-language.org/wiki/kbws) (Perl, Ruby, Python, Java)
   - [RPC/Encoded](http://www.g-language.org/wiki/kbws#rpc_encoded)
   - [Document/Literal](http://www.g-language.org/wiki/kbws#documentliteral)

#### Taverna workflow
Sample workflow for Taverna 2 is available from [here](http://www.myexperiment.org/workflows/1477.html).

### REST interface
User are able to access to REST interface through HTTP GET/POST methods.

Available method list is [here](http://soap.g-language.org/kbws/rest/methodlist).

#### Sample script (Perl)

    #!/usr/bin/env perl
    use LWP::Simple;
    use LWP::UserAgent;

    my $ua= LWP::UserAgent->new();
    my %param= (in0 => $seq);

    my $response= $ua->post('http://soap.g-language.org/kbws/rest/weblogo', \%param);

    my $jobid= $response->content();

    if ($jobid) {
        print "My Jobid is ",$jobid,"\n";
    } else {
        die "Failed calling ".$param{query}.". Server returns undefined jobid ($jobid)\n";
    }

    my $pollstar= 0;
    while (get('http://soap.g-language.org/kbws/rest/checkStatus/'.$jobid) == 0) {
        print '*';
        sleep 3;
    }
    print "\n" if $pollstar;

    print get('http://soap.g-language.org/kbws/rest/getResult/'.$jobid);

## Contact
Kazuki Oshita <cory@g-language.org>  
  Institute for Advanced Biosciences, Keio University.

[GPL]:http://www.gnu.org/licenses/gpl-2.0.html