xDrugSeller = xDrugSeller or {}

xDrugSeller = {
    MarkerColorR = 0, -- https://www.google.com/search?q=html+color+picker&rlz=1C1GCEA_enFR965FR965&oq=html+color+&aqs=chrome.2.69i59j0i131i433i512j0i512l5j69i60.3367j0j7&sourceid=chrome&ie=UTF-8
    MarkerColorG = 0, -- https://www.google.com/search?q=html+color+picker&rlz=1C1GCEA_enFR965FR965&oq=html+color+&aqs=chrome.2.69i59j0i131i433i512j0i512l5j69i60.3367j0j7&sourceid=chrome&ie=UTF-8
    MarkerColorB = 0, -- https://www.google.com/search?q=html+color+picker&rlz=1C1GCEA_enFR965FR965&oq=html+color+&aqs=chrome.2.69i59j0i131i433i512j0i512l5j69i60.3367j0j7&sourceid=chrome&ie=UTF-8
    MarkerOpacite = 200, 
    MarkerSaute = false, 
    MarkerTourne = false,

    --

    Banniere = "img_red", --Couleur de la banière : img_red, img_bleu, img_vert, img_jaune, img_violet, img_gris, img_grisf, img_orange
    CouleurMenu = "r", --"r" = rouge, "b" = bleu, "g" = vert, "y" = jaune, "p" = violet, "c" = gris, "m" = gris foncé, "u" = noir, "o" = orange
    Commande = "drugsell",

    JobPolice = {"police", "sherrif"},
    Drugs = {
        {Label =  "Weed", Name = "weed", MinPrice = 10, MaxPrice = 20},
        {Label =  "Cocaine", Name = "coke", MinPrice = 15, MaxPrice = 25}
    }
}