/* 
Version: v0.01
Written by Pavel Vojacek
codepoint.eu
license MIT
Copyright (c) 2014 Pavel Vojacek

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
*/
macroScript quickMask category:"corona" buttonText:"quickMask" tooltip:"Render quick mask from selection" silentErrors:true (
local elman = maxOps.GetRenderElementMgr #Production
local storedElements	
local maskElement
local gstore
local workingGid = 128
local selectionStore =#()

struct elementsSettings (
	enabled, 
	elementsActive=#(),
	on create do (		
		enabled = elman.GetElementsActive() 
		elman.setElementsActive true
		for i = 0 to (elman.NumRenderElements()-1) do 
			(
			el = elman.GetRenderElement i
			append elementsActive el.enabled
			el.enabled = false
			)
		),
	fn restore = (
		for i = 1 to (elman.NumRenderElements()-1) do (elman.GetRenderElement (i-1)).enabled = elementsActive[i]
		elman.SetElementsActive enabled	
		)		
	)
	
struct storeG (
	Gid = workingGid,
	storedObjects = #(),	
	on create do (
		for o in geometry where o.gbufferChannel == Gid do (
			append storedObjects o
			o.gbufferChannel = 0
			)	
		for o in geometry where classof o == Forest_Lite or classof o == Forest_Pro do
			(
				for f in o.cobjlist where f.gbufferChannel==Gid do (
					append storedObjects f
					f.gbufferChannel = 0
					)
				)
		),	
	fn restore = (
		for o in storedobjects do o.gbufferChannel = Gid		
		)
	)	

struct gSetting (obj, gid)	

fn storeElements = (	
	storedElements = elementsSettings()
	)

fn restoreElements = (
	storedElements.restore()	
	)	
	
fn AddMaskElement gid= (
	maskElement = CMasking_Mask elementname:"quickmask"
	maskElement.Mask_mono_Gbuffer_object = gid
	maskElement.use_mask_mono_object = true
	elman.addrenderelement maskelement	
	)
	
fn removeMaskElement = (
	elman.removerenderelement maskelement	
	)
	
fn storeGBuffers g = (	
	gstore = storeG()
	)
	
fn restoreGBuffers = (	
	gstore.restore()
	)
	
fn setSelectionGid gid = (
	for o in $ do 
		(
		if  classof o == Forest_Lite or classof o == Forest_Pro then (
			for f in o.cobjlist do (
					append selectionStore (gSetting obj:f gid:f.gbufferChannel)
					f.gbufferChannel = gid
					)
			)
		else (
			append selectionStore (gSetting obj:o gid:o.gbufferChannel)
			o.gbufferChannel = gid	
		)
		)
	)	
	
fn restoreSelectionGid = (
	for o in selectionStore do o.obj.gbufferChannel = o.gid	
	)	

fn renderMask = (
	if $!=undefined then
		(
			rsd = renderSceneDialog.isOpen()
			renderSceneDialog.close()
			storeElements()	
			AddMaskElement workingGid
			storeGBuffers workingGid
			setSelectionGid workingGid			
			timelimit = renderers.current.progressive_time_limit
			passlimit = renderers.current.Progressive_rendering_max_passes	
			renderers.current.progressive_time_limit = 0
			renderers.current.Progressive_rendering_max_passes = 3			
			CoronaRenderer.CoronaFp.renderElements true -- RENDER 
			renderers.current.progressive_time_limit = timelimit
			renderers.current.Progressive_rendering_max_passes = passlimit
			if rsd then renderSceneDialog.open()
			CoronaRenderer.CoronaFp.showvfb()
			CoronaRenderer.CoronaFp.setDisplayedChannel 2			
			restoreSelectionGid()	
			restoreGBuffers()
			restoreElements()	
			removeMaskElement()
			
		)
	)	
on execute do renderMask()
)
