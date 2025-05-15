macroScript RandomRenamer
	category:"Sams Tools"
	toolTip:"Random Renamer"
(
	try (DestroyDialog menu) catch()

	Rollout menu "Random Renamer" width:320 height:100
	(
		Spinner charCountSpinner "Character Count:" width:80 type:#integer range:[1,100,12] tooltip: "Number of characters per name generated"
		edittext validCharsField "Valid Chars:" text:"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789" tooltip: "List of characters to be randomly selected from"
		checkbox forceUniqueCheckbox "Force Unique" checked:true tooltip: "Should each name be forced to be unique?"
		
		--Apply Button
		button submitButton "Rename Selected"width:120 height:20 tooltip: "Rename selected objects with random strings"
		
		fn formatButtonString numObj = (
			return ((numObj as string) + " object(s)")
		)
		
		fn flattenNodes nodes = (
			i = 1
			while i <= nodes.count do (
				curNode = nodes[i]
				if isGroupHead curNode then (
					deleteItem nodes i --Remove the parent from the array

					for child in curNode.children do (
						append nodes child --Add children
					)
				) else (
					i += 1 --Only increment index if we havent removed the element at the current index
				)
			)
		)
		
		fn getRandomString validChars count = (
			result = ""
			for i = 1 to count do (
				append result (validChars[random 1 (validChars.count)])
			)
			
			return result
		)
		
		on submitButton pressed do
		(
			selectedObjs = $selection
			generatedNames = #()
			
			if selectedObjs != undefined and selectedObjs.count > 0 do
			(
				flattenNodes selectedObjs
				
				if forceUniqueCheckbox.checked then (
					--Ensure these names are unique with respect to other objects in the selection
					for obj in selectedObjs do (
						attempting = true
						while attempting do (
							newName = getRandomString validCharsField.text charCountSpinner.value
							
							unique = true
							for genName in generatedNames while unique do (
								if genName == newName then (
									unique = false
								)
							)
							
							if unique then (
								--Found a unique name so stop attempting
								print (obj.name + " renamed to: " + newName)
								obj.name = newName
								attempting = false
							)
						)
					)
				) else (
					for obj in selectedObjs do (
						--true random, no unique enforcement
						newName = getRandomString validCharsField.text charCountSpinner.value
						print (obj.name + " renamed to: " + newName)
						obj.name = newName
					)
				)
				
				DestroyDialog menu
			)
		)
	)

	CreateDialog menu
)
