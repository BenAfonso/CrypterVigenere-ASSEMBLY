# AFONSO Benjamin - Projet Archi IG3 par David 'MASTER OF MIPS' DELAHAYE
# Nom du Programme: CrypterVigenere.asm
# Specification: Encode/Decode une phrase ou un fichier texte d'après le principe de chiffrement de Vigenere. Sur la table ASCII Standard
# Implementation: MIPS Assembly

    #########################################################################
    ####################### ALLOCATIONS MEMOIRES ############################
    #########################################################################    
    
    .data
    inputKey: .asciiz "Entrez une cle d'encodage (50 caracteres maximum): "
    chosenKey: .asciiz "La cle choisie est : "
    firstMenu: .asciiz "============== MENU ==============\n1. Encoder\n2. Decoder\nVotre choix: "
    cryptChoice: .asciiz "\n1. Fichier texte\n2. Phrase\nVotre choix: "
    inputText: .asciiz "\nVeuillez saisir le texte: "
    inputFile: .asciiz "\nVeuillez saisir le fichier texte: "
    resText: .asciiz "\nLe resultat est:\n"
    resFile: .asciiz "\n Ne vous inquietez pas le resultat est stocké dans output.txt"
    resEnd: .asciiz "\n============== MENU ==============\n1. Quitter\n2.Recommencer\nVotre choix: "
    file: .space 50
    output: .asciiz "output.txt"
    text: .space 10000
    key: .space 50
    keyArray: .space 50
    textArray: .space 10000
    encode: .space 10000
     
    .text
     
    #########################################################################
    ######################## PROGRAMME PRINCIPAL ############################
    #########################################################################
     
    main:
            # Appel des routines
            jal menu
            move $s1,$t1
            jal input
            jal affichage
            jal typeEncodageChoix
            beq $t1,1,cryptFile
            beq $t1,2,cryptText
            beq $s1,1,encoder
            beq $s1,2,decoder
            jal stockerResultat
            
		

           
    #########################################################################
    #################### INTERACTIONS UTILISATEUR ###########################
    #########################################################################
     
    menu:
    	la $a0, firstMenu
    	la $v0,4
    	syscall
    	la $v0,5
    	syscall
    	la $t1,($v0)
    	jr $ra
    	
    #########################################################
    ########## DEMANDE DE LA CLE A L'UTILISATEUR ############
    #########################################################	
    
    # Routine demandant a l'utilisateur de saisir une cle d'encryption
    # Sortie: $t0 : String, Cle d'encryption
    input:
   	subi $sp , $sp , 4 	# Sauvegarde de l'adresse de la routine principale
	sw $ra , ( $sp )
            la $a0,inputKey
            li $v0,4
            syscall	# Affichage du message inputKey
            la $a0,key
            la $a1,50
            li $v0,8
            syscall	# Demande la clé à l'utilisateur
            la $a1, keyArray
            jal stockInArray
        lw $ra , ( $sp )	# On restaure l'adresse de la routine principale
	addi $sp , $sp , 4
	jr $ra		# Jump a la routine principale
		
           
    #########################################################
    ############# AFFIACHAGE DE LA CLE CHOISIE ##############
    #########################################################	     
    #  Routine affichant le choix de l'utilisateur pour la clï¿½    
    affichage:
            la $a0,chosenKey
            li $v0, 4
            syscall	# On affiche un message 
            la $a0,key
            li $v0,4
            syscall	# On affiche la clé choisie par l'utilisateur
            jr $ra
     
    #########################################################
    ############### CHOIX DU TYPE D'ENCODAGE ################
    #########################################################	
    # Routine demandant a l'utilisateur s'il veut encoder une phrase ou un fichier texte 
     
    typeEncodageChoix:
            la $a0,cryptChoice
            li $v0,4
            syscall
            li $v0,5
            syscall
            la $t1,($v0)
            jr $ra
           
           
    #########################################################
    ############## RECUPERATION D'UNE PHRASE ################
    #########################################################	
       
    cryptText:
    	subi $sp , $sp , 4
	sw $ra , ( $sp )

        la $a0,inputText	
        li $v0,4
        syscall		# On demande la saisie d'un texte a l'utilisateur
        li $a1,100
        la $a0,text	
        li $v0,8
        syscall		# On stock la phrase dans l'adresse de text (100 octets maximum)
        la $a1, textArray	# On prepare l'adresse d'accueil (Le tableau)
 	jal stockInArray	# On stock le texte dans le tableau TextArray
 	la $a0, textArray
 	li $v0, 4
 	syscall		# On affiche le contenu du tableau (phrase originale)
 	
	lw $ra , ( $sp )
	addi $sp , $sp , 4
	jr $ra
	
   #########################################################
   ###############  RECUPERATION D'UN FICHIER ##############
   #########################################################			


	cryptFile:
		subi $sp, $sp, 4
		sw $ra,( $sp )
		
		li $v0, 4
		la $a0, inputFile			
		syscall # Affichage de la demande du fichier text
		li $v0, 8
		la $a0, file
		la $a1, 200
		syscall # Récupération du nom du fichier saisi par l'utilisateur
		

				
		loop:				#remplace le "\n" par le caractï¿½re nul pour permettre la reconnaissance de fin de chaï¿½ne
			lb $t0, ($a0)
			beq $t0, 10, change
			addiu $a0, $a0, 1
			j loop
		
		change:
			li $t0, 0
			sb $t0, ($a0)
			
			li $v0, 13			
			la $a0, file
			li $a1, 0
			li $a2,0
			syscall			# On ouvre le fichier en mode lecture
			move $s0, $v0
			
 						
			li $v0, 14
			move $a0, $s0
			la $a1, text
			li $a2, 1000
			syscall		# Lecture des 10000 premiers caractères
			move $a0,$a1 # a0 Contient Text
			la $a1, textArray	# a1 Contient Array
			jal stockInArray			#appelle la routine pour stocker le contenu du fichier
			
							
			li $v0, 16	# Fermeture du fichier
			move $a0, $s0
			syscall
			
			lw $ra,($sp)
			addi $sp, $sp, 4		
			jr $ra


 		
		
    #########################################################
    ############### STOCKER DANS UN TABLEAU #################
    #########################################################	
    	
    stockInArray:
    	move $t0,$a0 #t0 :: TEXT
    	move $t1,$a1 #t1 :: ARRAY
    	
    for2:		# On boucle tant qu'on a pas rencontre le caractere zero. Fin de texte.
  	lb $t2, ($t0)
	sb $t2, ($t1)
	addiu $t0, $t0, 1
	addiu $t1, $t1, 1
	bnez $t2,for2
	move $v0, $t1
	jr $ra
		
 


		
    #########################################################
    #################### ENCODAGE ###########################
    #########################################################
    
    # Cle stockee dans un tableau keyArray
    # Texte stocke dans un tableau textArray
 	encoder:

 		li $v0,4
 		la $a0,resText
 		syscall
 		la $t0,textArray # TEXT ARRAY
 		la $t1,keyArray # KEY ARRAY
 		la $t2,encode
	reset: 
		la $t1,keyArray
	for3:	
		lb $t3,($t0) # On prends la valeur courante de textArray et on la met dans $t3
		lb $t4,($t1) # On prends la valeur de la cle courante
		beq $t4,10,reset
		
		
		addiu $t0,$t0,1	
		beq $t3,13,nochange	# Fin de ligne :: Pas d'opérations
		beq $t3,10,nochange	# Fin de ligne :: Pas d'opérations
		addiu $t1,$t1,1 # On incremente les deux
		beq $t3,0,endMenu # On arrete quand le caractère courant est 0
		# Modulo + Offset avec des additions / soustractions
		add $t4,$t4,$t3
		bge $t4,220,plus2
		bge $t4,127,plus
		
		j next
	plus:
		addiu $t4,$t4,-94 # Si $t4 est >= 126, on fait -94 CAR -126 + 32 (Offset: 32 ASCII)
		
		j next
	plus2:
		addiu $t4,$t4,-188 # Si $t4 est >= 220, on fait -188 car -220+32 = 188 (Offset: 32 ASCII)
		j next
	nochange:

		la $a0,($t3) # On affiche la valeur de t3 (cle)
		li $v0,11
		syscall		# On affiche la lettre encodee
		sb $a0,($t2)
		addiu $t2,$t2,1
		j for3
	next:
		la $a0,($t4) # On affiche la valeur de t3 (cle)
		li $v0,11
		syscall		# On affiche la lettre encodee
		sb $a0,($t2)
		addiu $t2,$t2,1
		
		bne $t3,0,for3 #On boucle tant que t2 n'est pas fini (texte)

		
		
#########################################################
#################### DECODAGE ###########################
#########################################################
    
    # Clï¿½ stockï¿½e dans un tableau keyArray
    # Texte stockï¿½ dans un tableau textArray
 	decoder:

		
 		li $v0,4
 		la $a0,resText
 		syscall
 		la $t0,textArray # TEXT ARRAY
 		la $t1,keyArray # KEY ARRAY
 		la $t2,encode
	reset2: 
		la $t1,keyArray
	for4:	
		lb $t3,($t0) # On prends la valeur courante de textArray et on la met dans $t3
		lb $t4,($t1) # On prends la valeur de la clï¿½ courante
		beq $t4,10,reset2	
		addiu $t0,$t0,1	
		beq $t3,13,nochange2	# Fin de ligne :: Pas d'opérations
		beq $t3,10,nochange2	# Fin de ligne :: Pas d'opérations
		addiu $t1,$t1,1 # On incrï¿½mente la clé
		beq $t3,0,endMenu	
		
		# Modulo + Offset avec des additions / soustractions
		neg $t4,$t4
		add $t4,$t3,$t4
		ble $t4,-63,plus3 
		ble $t4,31,plus4
		j next2
	plus3:
		addiu $t4,$t4,188 # Si $t4 est < -64, on fait +188
		j next2
	plus4:
		addiu $t4,$t4,94 # Si $t4 est < 32, on fait +94
		j next2
	nochange2:
		la $a0,($t3) # On affiche la valeur de t3 (cle)
		li $v0,11
		syscall		# On affiche la lettre encodee
		sb $a0,($t2)
		addiu $t2,$t2,1
		j for4
	next2:
		la $a0,($t4) # On affiche la valeur de t4
		li $v0,11
		syscall		# On affiche la lettre decodee
		sb $a0,($t2)
		addiu $t2,$t2,1
		bne $t3,0,for4	 #On boucle tant que t2 n'est pas fini (texte)

		
	
    #########################################################
    ############## STOCKER LE RESULTAT A FAIRE ##############
    #########################################################	    	
    	
    stockerResultat:
	li $v0, 13			#ouvre le fichier demandï¿½
	la $a0, output
	li $a1, 1
	li $a2,0
	syscall		
	move $s0, $v0
	
	# Ecriture dans le fichier OUTPUT
	
	li $v0,15
	move $a0,$s0
	la $a1,encode
	la $a2,1000
	syscall	
	
	li $v0, 16	# Fermeture du fichier
	move $a0, $s0
	syscall
			
	la $a0,resFile
	li $v0,4
	syscall

	jr $ra
 		
   	
   	
   	
    # Fin du programme     
    endMenu:
    	jal stockerResultat
    	la $a0,resEnd
    	li $v0,4
    	syscall		# Affichage du menu de fin
    	li $v0,5
    	syscall		# Prompt du choix utilisateur
    	beq $v0,1,end
    	beq $v0,2,main
    	
    	
    end:
    	li $v0,10
    	syscall		# Fermeture du programme
 

    
    	

