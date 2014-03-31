(
local elman = maxOps.GetRenderElementMgr #Production
local storedElements	
local maskElement
local gstore
local workingGid = 128
local selectionStore =#()
local timelimit = renderers.current.progressive_time_limit
local passlimit = renderers.current.Progressive_rendering_max_passes
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
	Gid = 128,
	storedObjects = #(),	
	on create do (
		for o in geometry where o.gbufferChannel == Gid do (
			append storedObjects o
			o.gbufferChannel = 0
			)
			
		),	
	fn restore = (
		for o in storedobjects do o.gbufferChannel = Gid		
		)
	)	

struct gSetting (obj, gid)	
	
--re = theManager.GetRenderElement 0
--re.use_mask_mono_nodes
--CoronaRenderer.CoronaFp.renderElements true

fn storeElements = (	
	storedElements = elementsSettings()
	)

fn restoreElements = (
	storedElements.restore()	
	)	
	
fn AddMaskElement gid= (
	maskElement = CMasking_Mask elementname:"quickmask"
	showproperties maskElement
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
		append selectionStore (gSetting obj:o gid:gid)
		o.gbufferChannel = gid	
		)
	)	
	
fn restoreSelectionGid = (
	for o in selectionStore do o.obj.gbufferChannel = o.gid	
	)	

fn renderMask = (
	if $!=undefined then
		(
			storeElements()	
			AddMaskElement workingGid
			storeGBuffers workingGid
			setSelectionGid workingGid
			renderers.current.progressive_time_limit = 0
			renderers.current.Progressive_rendering_max_passes = 3
			CoronaRenderer.CoronaFp.renderElements true
			renderers.current.progressive_time_limit = timelimit
			renderers.current.Progressive_rendering_max_passes = passlimit
			CoronaRenderer.CoronaFp.showvfb()
			CoronaRenderer.CoronaFp.setDisplayedChannel 2
			restoreSelectionGid()	
			restoreGBuffers()
			restoreElements()	
			removeMaskElement()
		)
	)
	
renderMask()
)