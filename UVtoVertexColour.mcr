macroScript UVtoVertColour
	category:"@Sams Tools"
	toolTip:"UV to Vertex Colour"
(
    try (DestroyDialog menu) catch()
	
	Rollout menu "UV to Vertex Colour" width:200 height:210
	(
        checkBox rCheck "Red" tooltip:"Overwrite the Red vertex colour channel by UV"
        checkBox gCheck "Green" tooltip:"Overwrite the Green vertex colour channel by UV"
        checkBox bCheck "Blue" tooltip:"Overwrite the Blue vertex colour channel by UV"
        checkBox aCheck "Alpha" tooltip:"Overwrite the Alpha vertex colour channel by UV"
        dropdownlist uvAxis "UV Axis" items:#("X", "Y") selection:2 width:50 tooltip:"UV axis to reference (U = X), (V = Y)"
        Spinner uvChannel "UV Channel" width:65 type:#integer range:[1,100,1] tooltip: "The UV Channel to reference."
        checkBox clampValue "Clamp values to 0-1" checked:true tooltip:"Should the vertex colour values be clamped between 0 and 1"
        button applySelection "Apply to Selected" tooltip:"Applies formatting options to all object(s) names within the selection." width:180

        fn UVtoVertColour obj mapchannel = (
            useRGB = rCheck.checked or gCheck.checked or bCheck.checked
            useAlpha = aCheck.checked
            useXAxis = uvAxis.selection == 1
            shouldClamp = clampValue.checked

            if useRGB then (polyop.setMapSupport obj 0 true)
            if useAlpha then (polyop.setMapSupport obj -2 true)

            visited = #{}
            visited.count = obj.numVerts

            for f = 1 to obj.numFaces do (
                if useRGB then (
                    uvVertsFace = polyop.getMapFace obj mapchannel f
                    colVertsFace = polyop.getMapFace obj 0 f

                    --Loop through all vertices in this face
                    for v = 1 to colVertsFace.count where not visited[colVertsFace[v]] do (

                        uv = polyop.getMapVert obj mapchannel uvVertsFace[v] --Get UV coord of our vert
                        vCol = if useXAxis then uv.x else uv.y

                        if shouldClamp then (
                            --Clamp value between 0 - 1
                            if vCol < 0 then vCol = 0
                            if vCol > 1 then vCol = 1
                        )

                        origCol = polyop.getMapVert obj 0 colVertsFace[v]

                        r = if rCheck.checked then vCol else origCol.x
                        g = if gCheck.checked then vCol else origCol.y
                        b = if bCheck.checked then vCol else origCol.z

                        polyop.setMapVert obj 0 colVertsFace[v] (color r g b)

                        visited[colVertsFace[v]] = true
                    )
                )

                if useAlpha then (
                    visited = #{}
                    visited.count = obj.numVerts

                    uvVertsFace = polyop.getMapFace obj mapchannel f
                    colVertsFace = polyop.getMapFace obj -2 f
    
                    --Loop through all vertices in this face
                    for v = 1 to colVertsFace.count where not visited[colVertsFace[v]] do (
                        
                        uv = polyop.getMapVert obj mapchannel uvVertsFace[v] --Get UV coord of our vert
                        vCol = if useXAxis then uv.x else uv.y
    
                        if shouldClamp then (
                            --Clamp value between 0 - 1
                            if vCol < 0 then vCol = 0
                            if vCol > 1 then vCol = 1
                        )
    
                        polyop.setMapVert obj -2 colVertsFace[v] (color vCol vCol vCol)
    
                        visited[colVertsFace[v]] = true
                    )
                )
            )
        )

        on applySelection pressed do (
            if rCheck.checked or gCheck.checked or bCheck.checked or aCheck.checked then (
                undo "UV to Vertex Color" on
                (
                    uvChnl = uvChannel.value
                    invMapChannelCnt = 0
                    for obj in selection do (
                        if polyop.getMapSupport obj uvChnl then (
                            UVtoVertColour obj uvChnl
                            obj.showVertexColors
                        ) else (
                            invMapChannelCnt += 1
                        )
                    )

                    if invMapChannelCnt > 0 then (
                        messageBox ((invMapChannelCnt as string) + " object(s) in the selection do not support UV channel " + (uvChnl as string) + "!")
                    )

                    redrawViews() --force polypaint preview to update in viewport
                )
            ) else (
                messageBox ("No RGBA colour channel selected! please select at least one channel.")
            )
        )
    )

    CreateDialog menu
)