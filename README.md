LyncOnline_ACP_AutoProvisioning
===============================

Auto provisioning of PGi Clients, Audio Conferences and ACP integration of the same into Lync Online accounts. http://uk.pgi.com/wp-content/uploads/GMAudio-Lync-Datasheet-FINAL.pdf

This is a Proof Of Concept code to show that is is possible to create a Workflow where you automate the process of creation of PGi Client accounts, an Audio Conference and to integrate that Audio conference in to a Lync Online account to provide ACP (Audio Conference Provider) integration into the Lync Online account.


The code shows how to

    * Authenticate to the Public PGI API
    * Create a Client under a given Company within the PGi Backend
    * Create an (Audio) Conference for the created Client to be used with Lync Online
    * Retrieve the conference details (Toll & Toll Free phone numbers and Passcode)
    * Integrate the conference details in a Lync Online user account
