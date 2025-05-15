macroScript FindObjectsWithinSize
	category:"Sams Tools"
	toolTip:"Find Objects Within Size"
(
	try (DestroyDialog menu) catch()
	
	Rollout menu "Find Objects Within Size" width:200 height:80
	(
        spinner sizeSpinner "Check Size:" type:#worldUnits range:[0,1000,1] pos:[20, 10] 
        button applyButton "Select Objects within Size" tooltip:"Selects all objects that are within the check size value on all axes" pos:[30, 30] 

        on applyButton pressed do
		(
            fn isObjectWithinSize obj = (
                local checkSize = sizeSpinner.value
                local bb = (nodeGetBoundingBox obj obj.transform)[2]
                bb.x < checkSize and bb.y < checkSize and bb.z < checkSize
            )

            validNodes = for obj in objects where isObjectWithinSize obj and not obj.isHiddenInVpt collect obj
            select validNodes
            messageBox ((validNodes.count as string) + " object(s) selected!")

            DestroyDialog menu
        )
	)
	CreateDialog menu
)