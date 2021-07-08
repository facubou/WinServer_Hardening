Function SecuringServer {

    #Declaro parametros
    Param (
        [string]$equipoRemoto,
        [boolean]$local = $false 
    ) 

    #valido que no tenga ambos parametros
    if ($local -eq $true -and -not ([string]::IsNullOrEmpty($equipoRemoto))) 
    {
        Write-Host "No puede ser local y remoto al mismo tiempo"
        Read-Host -Prompt "Presione una tecla para finalizar"
        Exit
    }

    if ($local -eq $true) #Entra en local
    {

        Write-Host "entro en local" 
        $hostname = hostname
        $tipoServer = ""

        #Valido que sea SQL o NoSQL
        while (-not ($tipoServer -eq "NoSQL" -or $tipoServer -eq "SQL")) 
        {
            $tipoServer = Read-Host -Prompt "SQL or NoSQL" 
        }
        
        if ($tipoServer -eq "NoSQL")
        {
            $DistingueshedName = Get-ADComputer -Filter "Name -like '$hostname'" -SearchBase "DC=contoso, DC=com, DC=ar" -properties DistinguishedName | select-object -ExpandProperty DistinguishedName
            $listaSADMNET = Get-ADComputer -Filter * -SearchBase "OU=Servers, DC=contoso, DC=com, DC=ar" -properties Name | select-object -ExpandProperty Name

            Write-Host "El equipo se encuentra en --> $DistingueshedName"

            #compruebo si el hostname esta dentro de la OU 
            if (select-string -pattern $hostname -InputObject $listaSADMNET){ 
                Write-Host "Compliance" -ForegroundColor Green
            }
            if (-not(select-string -pattern $hostname -InputObject $listaSADMNET)){
                Write-Host "No Compliance" -ForegroundColor Red
                $mover = Read-Host -Prompt "Mover de OU el Equipo? si/no"
                if ($mover -eq "si"){
                    Write-Host "Moviendo a OU=SIN ADMNET"
                    #Get-ADComputer -Filter "Name -like '$hostname'" | Move-ADObject -TargetPath "OU=Servers, DC=contoso, DC=com, DC=ar"
                }
            }
        }        
        
    }

    #Verifica si se selecciono la opcion equipo remoto
    if (-not ([string]::IsNullOrEmpty($equipoRemoto))){

        Write-Host "entro en remoto"

        $tipoServer = ""

        while (-not ($tipoServer -eq "NoSQL" -or $tipoServer -eq "SQL")){
            $tipoServer = Read-Host -Prompt "SQL or NoSQL" 
        }
        
        if ($tipoServer -eq "NoSQL")
        {

            #Get-ADComputer -Filter * -SearchBase "OU=Servers, DC=contoso, DC=com, DC=ar" -properties Name | select-object -ExpandProperty Name

        }
    }

}

#Comentario
