# AFONSO Benjamin - Projet Archi IG3 par David 'MASTER OF MIPS' DELAHAYE
# Nom du Programme: CrypterVigenere.asm
# Specification: Encode/Decode une phrase ou un fichier texte d'apr�s le principe de chiffrement de Vigenere. Sur la table ASCII Standard
# Implementation: MIPS Assembly

    #########################################################################
    ####################### ALLOCATIONS MEMOIRES ############################
    #########################################################################    
    
    .data
    inputKey: .asciiz "Entrez une cle d'encodage (50 caracteres maximum): "
    chosenKey: .asciiz "La cle choisie est : "
    firstMenu: .asciiz "\nVoulez vous encoder (Entrez 1) ou decoder (Entrez 2): "
    cryptChoice: .asciiz "Voulez vous encoder un fichier texte (Entrez 1) ou une phrase (Entrez 2): "
    inputText: .asciiz "\nVeuillez saisir le texte: "
    inputFile: .asciiz "\nVeuillez saisir le fichier texte: "
    resText: .asciiz "\nLe resultat est: "
    resFile: .asciiz "\nLe resultat est stock� dans: "
    file: .space 50
    output: .asciiz "output.txt"
    text: .space 1000
    key: .space 50
    keyArray: .space 50
    textArray: .space 1000
    encode: .space 100
     
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
            
		
            # Fin du programme
            j end
            li $v0,10
           
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
            syscall
            la $a0,key
            la $a1,50
            li $v0,8
            syscall
            la $a1, keyArray
            jal stockInArray
        lw $ra , ( $sp )	# On restaure l'adresse de la routine principale
	addi $sp , $sp , 4
	jr $ra		# Jump a la routine principale
		
           
    #########################################################
    ############# AFFIACHAGE DE LA CLE CHOISIE ##############
    #########################################################	     
    #  Routine affichant le choix de l'utilisateur pour la cl�    
    affichage:
            la $a0,chosenKey
            li $v0, 4
            syscall
            la $a0,key
            li $v0,4
            syscall
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
		syscall # R�cup�ration du nom du fichier saisi par l'utilisateur
		

				
		loopC:				#remplace le "\n" par le caract�re nul pour permettre la reconnaissance de fin de cha�ne
			lb $t0, ($a0)
			beq $t0, 10, changeC
			addiu $a0, $a0, 1
			j loopC
		
		changeC:
			li $t0, 0
			sb $t0, ($a0)
			
			li $v0, 13			#ouvre le fichier demand�
			la $a0, file
			li $a1, 0
			li $a2,0
			syscall		
			move $s0, $v0
			
 		readC:					#lire les 1000 premiers caract�res du fichier
			li $v0, 14
			move $a0, $s0
			la $a1, text
			li $a2, 1000
			syscall		# Lecture du buffer texte
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
    ############## STOCKER LE RESULTAT A FAIRE ##############
    #########################################################	    	
    	
    stockerResultat:
    	li $v0, 13			#ouvre le fichier demand�
	la $a0, output
	li $a1, 0
	li $a2,0
	syscall		
	move $s0, $v0
	
	# Ecriture dans le fichier OUTPUT
	
	li $v0,15
	move $a0,$s0
	la $a1,text
	la $a2,1000
	syscall
 		
		
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
		beq $t3,13,nochange	# Fin de ligne :: Pas d'op�rations
		beq $t3,10,nochange	# Fin de ligne :: Pas d'op�rations
		addiu $t1,$t1,1 # On incremente les deux
		beq $t3,0,end # On arrete quand le caract�re courant est 0
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
		j for3
	next:
		la $a0,($t4) # On affiche la valeur de t3 (cle)
		li $v0,11
		syscall		# On affiche la lettre encodee
		sb $a0,encode
		
		bne $t3,0,for3 #On boucle tant que t2 n'est pas fini (texte)
		jr $ra
		
		
#########################################################
#################### DECODAGE ###########################
#########################################################
    
    # Cl� stock�e dans un tableau keyArray
    # Texte stock� dans un tableau textArray
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
		lb $t4,($t1) # On prends la valeur de la cl� courante
		beq $t4,10,reset2	
		addiu $t0,$t0,1	
		beq $t3,13,nochange2	# Fin de ligne :: Pas d'op�rations
		beq $t3,10,nochange2	# Fin de ligne :: Pas d'op�rations
		addiu $t1,$t1,1 # On incr�mente la cl�
		beq $t3,0,end	
		
		# Modulo + Offset avec des additions / soustractions
		neg $t4,$t4
		add $t4,$t3,$t4
		ble $t4,-63,plus3 
		ble $t4,31,plus4
		jal next2
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
		j for4
	next2:
		la $a0,($t4) # On affiche la valeur de t4
		li $v0,11
		syscall		# On affiche la lettre decodee
		

		bne $t3,0,for4	 #On boucle tant que t2 n'est pas fini (texte)
		j end
		
	
		
 		
   	
   	
   	
    # Fin du programme     
    end:
    	j main

    
    	

