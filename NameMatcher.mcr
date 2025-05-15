macroScript NameMatcher
	category:"Sams Tools"
	toolTip:"Name Matcher"
(
	try (DestroyDialog menu) catch()
	
	Rollout menu "Name Matcher" width:340 height:120
	(
		local targetObjs = #()
		local refObjs = #()
		
		local refObjBBCache = #()
		
		label targetLabel "Target Objects" pos:[35,16]
		button targetObjSelectButton "0 object(s)" tooltip:"Select target objects to rename" pos:[110,13] width:90 height:20
		label suffixLabel "Add Suffix" pos:[210,16]
		edittext targetSuffix tooltip:"Optional suffix to add to the end of each name" pos:[262,13] width:50 height:20
		
		label refLabel "Reference Objects" pos:[15,41]
		button refObjselectButton "0 object(s)" tooltip:"Select reference objects" pos:[110,38] width:90 height:20
		
		--Apply Button
		button applyButton "Rename Target Objects" tooltip:"Rename all target objects based on their respective closest matching reference object" pos:[100, 80] width:140 height:20
		
		fn formatButtonString numObj = (
			return ((numObj as string) + " object(s)")
		)
		
		fn flattenNodes nodes = (
			i = 1
			while i <= nodes.count do (
				curNode = nodes[i]
				if isGroupHead curNode then (
					deleteItem nodes i --Remove the parent from the array
				) else (
					i += 1 --Only increment index if we havent removed the element at the current index
				)

				for child in curNode.children do (
					append nodes child --Add children
				)
			)
		)
		
		fn getBounds obj = (
			return nodeGetBoundingBox obj (matrix3 1) --get worldspace bounding box positions
		)
		
		fn bbOverlapTest minA maxA minB maxB = (
			--Check for overlap along the x-axis
			if maxA.x + 0.001 < minB.x or minA.x > maxB.x + 0.001 then (
				return false
			)
				
			--Check for overlap along the y-axis
			if maxA.y + 0.001 < minB.y or minA.y > maxB.y + 0.001 then (
				return false
			)

			--Check for overlap along the z-axis
			if maxA.z + 0.001 < minB.z or minA.z > maxB.z + 0.001 then (
				return false
			)

			--If all checks passed, bounding boxes overlap
			return true
		)
		
		on targetObjSelectButton pressed do
		(
			targetObjs = selectByName title:"Select Target Objects" buttonText:"Select" showHidden:true single:false
			
			if targetObjs != undefined and targetObjs.count > 0 do
			(
				flattenNodes targetObjs
				targetObjSelectButton.text = (formatButtonString targetObjs.count)
			)
		)
		
		on refObjselectButton pressed do
		(
			refObjs = selectByName title:"Select Reference Objects" buttonText:"Select" showHidden:true single:false
			
			if refObjs != undefined and refObjs.count > 0 do
			(
				flattenNodes refObjs
				refObjselectButton.text = (formatButtonString refObjs.count)
			)
		)
		
		on applyButton pressed do
		(
			if (targetObjs != undefined and targetObjs.count > 0) and (refObjs != undefined and refObjs.count > 0) then (
				
				renamedCount = 0
				objectsMissingRef = #()

				for i = 1 to refObjs.count do (
					
					refObj = refObjs[i]
					-- Get the bounding box of the object
					bb = getBounds refObj
					minPoint = bb[1]
					maxPoint = bb[2]
					
					refObjBBCache[i] = #(minPoint, maxPoint, refObj)
				)
				
				for j = 1 to targetObjs.count do (
						
					targetObj = targetObjs[j]
					
					closestDistToRef = 9999999
					closestRefObj = undefined
					
					-- Get the bounding box of the object
					targBB = getBounds targetObj
					minPointTarget = targBB[1]
					maxPointTarget = targBB[2]
					
					for k = 1 to refObjs.count do (
						refCache = refObjBBCache[k]
						minPointRef = refCache[1]
						maxPointRef = refCache[2]
						
						dist = (distance minPointTarget minPointRef) + (distance maxPointTarget maxPointRef)
						
						if dist < closestDistToRef then (
							closestDistToRef = dist
							closestRefObj = refCache[3]
						)
					)

					if closestRefObj != undefined then (
						refBB = getBounds closestRefObj
						minPointRef = refBB[1]
						maxPointRef = refBB[2]
						
						if bbOverlapTest minPointRef maxPointRef minPointTarget maxPointTarget then (
							nameNew = (closestRefObj.name + targetSuffix.text);

							if nameNew != targetObj.name then (
								print ("Renaming object: \"" + targetObj.name + "\" to: \"" + nameNew + "\"")
								targetObj.name = nameNew
								renamedCount += 1
							) else (
								print ("Names already matching for pair: \"" + targetObj.name + "\" and: \"" + nameNew + "\"")
							)
						) else (
							print ("WARNING: \"" + targetObj.name + "\" DOES NOT OVERLAP WITH ANY REFERENCE OBJECT!")
							append objectsMissingRef targetObj
						)
					)
				)
				
				select objectsMissingRef
				
				overlappingPairCount = targetObjs.count - objectsMissingRef.count
				messageBox ((renamedCount as string) + " object(s) renamed! " + (overlappingPairCount as string) + " object pairs found! Selected " + (objectsMissingRef.count as string) + " object(s) missing an overlapping reference object!")

				DestroyDialog menu
			) else (
				messageBox "Target Objects and Reference Objects fields must be populated!"
			)
		)
	)

	CreateDialog menu
)
