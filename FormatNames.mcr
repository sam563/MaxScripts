macroScript FormatNames
	category:"Sams Tools"
	toolTip:"Format Names"
(
	try (DestroyDialog menu) catch()
	
	Rollout menu "Format Names" width:200 height:150
	(
        edittext targetPrefix "Prefix" tooltip:"Optional prefix to add to the start of each name"
        edittext targetSuffix "Suffix" tooltip:"Optional suffix to add to the end of each name"
        edittext removeChars "Remove Characters" tooltip: "Characters to remove from each name"
        dropdownlist casing "Casing Options" items:#("None", "Force Lower", "Force Upper")
        button applyButton "Apply formatting to selection" tooltip:"Applies formatting options to all object(s) names within the selection."

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

        fn cleanString str = (
            strArr = filterString str removeChars.text

            result = ""
            for c in strArr do (
                result += c
            )

            return result
        )

        on applyButton pressed do
		(
            renameObjs = #()
            renamedObjsCount = 0

            for sel in selection do (
                append renameObjs sel
            )

            flattenNodes renameObjs

            undo on (
                for obj in renameObjs do (
                    nameStr = cleanString obj.name
                    if casing.selection > 1 then (
                        if casing.selection == 2 then  (
                            nameStr = toLower nameStr
                        ) else (
                            nameStr = toUpper nameStr
                        )
                    )
                    nameStr = targetPrefix.text + nameStr + targetSuffix.text

                    if obj.name != nameStr then (
                        obj.name = nameStr
                        renamedObjsCount += 1
                    )
                )
            )
            messageBox ((renamedObjsCount as string) + " object(s) renamed!")

            DestroyDialog menu
        )
	)
	CreateDialog menu
)