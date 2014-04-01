coronaQuickMask
===============

Render super fast mask from selection.

# How to run

[Download](https://raw.githubusercontent.com/pavel-mxsf/coronaQuickMask/master/coronaQuickMask.mcr) coronaQuickmask.mcr and copy to usermacros folder (c:\Users\username\AppData\Local\Autodesk\3dsMax\2014 - 64bit\ENU\usermacros\ )

Drag and drop to viewport should work too.

In Customize - Customize User Interface select Quads - category corona and drag "Render quick mask from selection" to the right window.

You should have Render quick mask from selection on right-click quad menu.

# How it works

It uses Render only elements function from corona (Actions rollout) nad CMasking_mask element. 
Adds Element - store objects GBuf IDs - renders - shows output - reverts GBuf IDs changes.
Output is antialiased with 3 corona passes (other settings untouched).

# Updates

- 01/04/2014 itoo forest support

# TODO

- ?
