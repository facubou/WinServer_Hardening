$tipoServer =""
Function SecurizaServer {

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

        #Valido que sea SQL o NoSQL
        while (-not ($tipoServer -eq "NoSQL" -or $tipoServer -eq "SQL")) 
        {
            $tipoServer = Read-Host -Prompt "SQL or NoSQL" 
        }
        
        if ($tipoServer -eq "NoSQL")
        {
            CompruebaOU $hostname
            $localUsers = Get-LocalUser #trae los usuarios locales del equipo

            #busco si el usuario administrador o administrator esta dentro de usuarios locales
            Write-Host "`n Buscando usuarios administradores locales..."
            sleep -seconds 2
            if ((select-string -pattern "Administrator" -InputObject $localUsers) -or (select-string -pattern "Administrador" -InputObject $localUsers))
                {
                    ChangeADM
                }
            else{
                Write-Host "`n No se encontro usuario administrador local" -ForegroundColor Red
            }    
        }        
        
    }


#------------------------------------------------------------------------#

    #Entra en Remoto
    if (-not ([string]::IsNullOrEmpty($equipoRemoto))){

        Write-Host "`n entro en remoto"

        while (-not ($tipoServer -eq "NoSQL" -or $tipoServer -eq "SQL")){
            $tipoServer = Read-Host -Prompt "SQL or NoSQL" 
        }
        
        if ($tipoServer -eq "NoSQL")
        {

            #Get-ADComputer -Filter * -SearchBase "OU=SIN ADMNET, OU=SERVIDORES, DC=bice, DC=com, DC=ar" -properties Name | select-object -ExpandProperty Name

        }
    }

}

Function CompruebaOU ($hostname){

    $DistingueshedName = Get-ADComputer -Filter "Name -like '$hostname'" -SearchBase "DC=bice, DC=com, DC=ar" -properties DistinguishedName | select-object -ExpandProperty DistinguishedName
    $listaSADMNET = Get-ADComputer -Filter * -SearchBase "OU=SIN ADMNET, OU=SERVIDORES, DC=bice, DC=com, DC=ar" -properties Name | select-object -ExpandProperty Name

    Write-Host "El equipo se encuentra en --> $DistingueshedName"

    #compruebo si el hostname esta dentro de la OU SINADMNET
    if (select-string -pattern $hostname -InputObject $listaSADMNET){ 
        Write-Host "`n Compliance" -ForegroundColor Green
    }
    if (-not(select-string -pattern $hostname -InputObject $listaSADMNET)){
        Write-Host "`n No Compliance" -ForegroundColor Red
        $mover = Read-Host -Prompt "`n Mover de OU el Equipo? si/no"
        if ($mover -eq "si"){
            Write-Host "`n Moviendo a OU=SIN ADMNET..."
            sleep -seconds 2
            #Get-ADComputer -Filter "Name -like '$hostname'" | Move-ADObject -TargetPath "OU=SIN ADMNET, OU=SERVIDORES, DC=bice, DC=com, DC=ar"
            if (select-string -pattern $hostname -InputObject $listaSADMNET){
                Write-Host "`n Movido Exitosamente" -ForegroundColor Green
            }
            if (-not(select-string -pattern $hostname -InputObject $listaSADMNET)){
                Write-Host "`n No se pudo mover de OU" -ForegroundColor Red
            }
        }
    }
}

Function ReadPass{
    Write-Host "`n Ingrese Nueva Password"
    $Password = Read-Host -AsSecureString
    return $Password
}

Function ReadName{
    $username = Read-Host "`n Nuevo nombre para Administrador"
    return $username
}

Function ChangeADM{
    $userAdm = Get-LocalUser -Name "Adminis*" | select Name -ExpandProperty Name
    Write-Host "`n Encontrado: $userAdm" -ForegroundColor Green
    $rta = Read-Host "Desea realizar cambios sobre el usuario $userAdm ? si/no"
    if ($rta -eq "si"){
        sleep -seconds 1
        $newName = ReadName
        Write-Host "`n Renombrando $userAdm ..."
        sleep -seconds 2
        #Rename-LocalUser -Name $userAdm -NewName $newName
        Write-Host "`n Realizado" -ForegroundColor Green 
        sleep -seconds 1
        $pass = ReadPass
        Write-Host $pass
        Write-Host "Cambiando password de $newName ..."
        sleep -seconds 1
        #Set-LocalUser -Name Administrator -Password ReadPass  
        Write-Host "`n Se cambio la password del usuario $newName" -ForegroundColor Green
    }
    else {
        sleep -seconds 1
        Write-Host "`n No se realizaron cambios sobre el usuario"
    }
    $crearAdm = Read-Host "`n Crear usuario Adm (sin permisos) si/no?"
    if ($crearAdm -eq "si"){
        $nombre = Read-Host "`n Nombre de usuario: "
        $pass = Read-Host "Password (minimo 8 + mayus + Char) " -AsSecureString
        New-LocalUser -Name $nombre -Password $pass
        if (Get-LocalUser -Name "$nombre"){
            Write-Host "`n Se creo el usuario exitosamente" -ForegroundColor Green
        }
        else{
            Write-Host "`n No se pudo crear el usuario" -ForegroundColor Red
        }
    }
}
