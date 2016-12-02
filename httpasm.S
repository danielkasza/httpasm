#define CONSOLE_DATA_REGISTER 0xB0000000
#define CONSOLE_HALT_REGISTER 0xB0000010

#define ETHER_BUFFER          0xB4000000
#define ETHER_STATUS_REGISTER 0xB4004000
#define ETHER_LENGTH_REGISTER 0xB4004010
#define ETHER_CMD_REGISTER    0xB4004020

#define HTTP_BAD_REQUEST_STRING     "400 Bad Request"
#define HTTP_BAD_REQUEST_STRING_LEN 15

#define HTTP_NOT_FOUND_STRING       "404 Not Found"
#define HTTP_NOT_FOUND_STRING_LEN   13

#define HTTP_HOME_STRING "<!DOCTYPE html><meta charset=utf-8><title>Untitled Document.md</title><style></style><body id=preview><h1><a id=HTTPAsm_0></a>HTTPAsm</h1><p><em>The world’s crappiest webserver and TCP/IP stack, written in MIPS assembly.</em><h2><a id=Features_4></a>Features</h2><ul><li>100% MIPS assembly.<li>Runs on GXemul.<li>Serves a small static web pages with <code>GET</code> method.<li>Server can be remotely shut down with <code>POST</code> method.<li>Works with Google Chrome.<li>Requires no network configuration. It assumes all IP addresses and TCP ports.<li>Responds to ping.<li>Contains a terribly hacky stateless TCP/IP implementation.<li>Difficult to read.</ul><form method=POST><input type=submit value=\"Shut down server\"></form>"
#define HTTP_HOME_STRING_LEN        732

#define HTTP_SHUTDOWN_STRING "<!DOCTYPE html><meta charset=utf-8><title>Untitled Document.md</title><style></style><body id=preview><h1><a id=HTTPAsm_0></a>HTTPAsm</h1><p>Thank you for trying HTTPAsm!<p>The server is now shutting down."
#define HTTP_SHUTDOWN_STRING_LEN    205

#define PUTCHAR( reg ) sb reg, CONSOLE_DATA_REGISTER
#define EXIT() sb $0, CONSOLE_HALT_REGISTER


/** Size of HTTP request buffer. */
#define HTTP_BUFFER_SIZE 1500

/** Entry point of the program. */
.extern "main"
main:
    /* Print startup message. */
    la $a0, startup_msg
    jal putstring

    /* Loop forever. */
loop:
    jal tcp_update
    j loop

    EXIT()

/** Print string to console.
 * @warning modifies $a0, $a1!
 * @param $a0 address of '\0' terminated string to print.
 */
.extern "putstring"  
putstring:
    /* Load character. */
    lbu $a1, 0($a0)
    /* while (char != 0) */
    bne $a1, $0, _putstring_while_inner
    jr $ra
_putstring_while_inner:
    PUTCHAR($a1)
    addiu $a0, $a0, 1
    j putstring

/** Print string to console, using length, not '\0' termination.
 * @warning modifies $a0, $a1, $a2!
 * @param $a0 address of string to print.
 * @param $a1 length of string.
 */
.extern "putstringn" 
putstringn:
    addu $a1, $a1, $a0
_putstringn_while:
    beq $a0, $a1, _putstringn_return
    lbu $a2, 0($a0)
    PUTCHAR($a2)
    addiu $a0, $a0, 1
    j _putstringn_while
_putstringn_return:
    jr $ra

/* -- TCP/IP CODE BEGINS -- */

/** Update TCP/IP network state machine. */
.extern "network_update"
tcp_update:
    /* Are there any pending Ethernet frames? */
    lbu $t0, ETHER_STATUS_REGISTER
    li $t1, 2
    and $t0, $t0, $t1
    beq $t0, $t1, _tcp_update_receive_frame
    /* Nope. */
    jr $ra
_tcp_update_receive_frame:
    li $t0, '\n'
    PUTCHAR($t0)
    /* Ask for the frame. */
    sb $0, ETHER_CMD_REGISTER
    /* Get frame type */
    lhu $t0, (ETHER_BUFFER + 12)
    /* Is this arp? */
    li $t1, 0x0806
    beq $t0, $t1, _tcp_update_handle_arp
    /* Is this IP? */
    li $t1, 0x0800
    beq $t0, $t1, _tcp_update_handle_ip
    /* Others are simply ignored. */
    jr $ra

_tcp_update_handle_arp:
    li $t0, 'A'
    PUTCHAR($t0)
    /* Blindly respond to any ARP request.
     * Basically, this node does not have an IP. It has all IPs.
     * Also, the node uses the MAC address: AA:BB:CC:DD:EE:FF
     */
    /* Set operation in arp. */
    li $t0, 2
    sh $t0, (ETHER_BUFFER + 20)
    /* Set target & sender addresses in arp. */
    lb $t0, (ETHER_BUFFER + 22)
    sb $t0, (ETHER_BUFFER + 32)
    lb $t0, (ETHER_BUFFER + 23)
    sb $t0, (ETHER_BUFFER + 33)
    lb $t0, (ETHER_BUFFER + 24)
    sb $t0, (ETHER_BUFFER + 34)
    lb $t0, (ETHER_BUFFER + 25)
    sb $t0, (ETHER_BUFFER + 35)
    lb $t0, (ETHER_BUFFER + 26)
    sb $t0, (ETHER_BUFFER + 36)
    lb $t0, (ETHER_BUFFER + 27)
    lb $t1, (ETHER_BUFFER + 37)
    sb $t0, (ETHER_BUFFER + 37)
    sb $t1, (ETHER_BUFFER + 27)
    lb $t0, (ETHER_BUFFER + 28)
    lb $t1, (ETHER_BUFFER + 38)
    sb $t0, (ETHER_BUFFER + 38)
    sb $t1, (ETHER_BUFFER + 28)  
    lb $t0, (ETHER_BUFFER + 29)
    lb $t1, (ETHER_BUFFER + 39)
    sb $t0, (ETHER_BUFFER + 39)
    sb $t1, (ETHER_BUFFER + 29)
    lb $t0, (ETHER_BUFFER + 30)
    lb $t1, (ETHER_BUFFER + 40)
    sb $t0, (ETHER_BUFFER + 40)
    sb $t1, (ETHER_BUFFER + 30)
    lb $t0, (ETHER_BUFFER + 31)
    lb $t1, (ETHER_BUFFER + 41)
    sb $t0, (ETHER_BUFFER + 41)
    sb $t1, (ETHER_BUFFER + 31)
    li $t0, 0xAABB
    sh $t0, (ETHER_BUFFER + 22)
    li $t0, 0xCCDD
    sh $t0, (ETHER_BUFFER + 24)
    li $t0, 0xEEFF
    sh $t0, (ETHER_BUFFER + 26)
    /* Set source and destination MAC in Ethernet header. */
    li $t0, 0xFFFFFFFF
    sw $t0, (ETHER_BUFFER + 0)
    li $t0, 0xFFFFAABB
    sw $t0, (ETHER_BUFFER + 4)
    li $t0, 0xCCDDEEFF
    sw $t0, (ETHER_BUFFER + 8)
    /* Send frame. */
    li $t0, 1
    sb $t0, ETHER_CMD_REGISTER
    jr $ra

_tcp_update_handle_ip:
    li $t0, 'I'
    PUTCHAR($t0)
    /* Check version and header length.
     * We do not handle options, so this must always be 0x45.
     */
    li $t0, 0x45
    lbu $t1, (ETHER_BUFFER + 14)
    bne $t1, $t0, _tcp_update_handle_ip_ignore
    /* For now, we can ignore the checksum and most other fields. */
    /* Get the protocol id. */
    lb $t0, (ETHER_BUFFER + 23)
    /* Is this ICMP? (ping) */
    li $t1, 1
    beq $t0, $t1, _tcp_update_handle_icmp
    /* Is this TCP? */
    li $t1, 6
    beq $t0, $t1, _tcp_update_handle_tcp    
    /* Others are simply ignored. */
_tcp_update_handle_ip_ignore:
    jr $ra
    
_tcp_update_handle_icmp:
    li $t0, 'P'
    PUTCHAR($t0)
    /* Just assume it's an Echo Request, and convert it to an Echo Reply. */
    sb $0, (ETHER_BUFFER + 34)
    /* Switch Ethernet and IP addresses (dst<->src). */
    move $a0, $ra
    jal swap_ethernet_addresses
    jal swap_ip_addresses
    /* Fix IP checksum. */
    jal do_ip_checksum
    move $ra, $a0
    /* Fix ICMP checksum. */
    lhu $t0, (ETHER_BUFFER + 36)
    addiu $t0, $t0, 0x800
    sh $t0, (ETHER_BUFFER + 36)
    /* Send. */
    li $t0, 1
    sb $t0, ETHER_CMD_REGISTER
    jr $ra

_tcp_update_handle_tcp:
    li $t0, 'T'
    PUTCHAR($t0)
    /* Get TCP flags. */
    lh $t0, (ETHER_BUFFER + 46)
    li $t1, 0x0FFF
    and $t0, $t0, $t1
    /* Is this a SYN?
     * If so, we'll reply with SYN+ACK.
     */
    li $t1, 0x02
    beq $t0, $t1, _tcp_update_handle_tcp_syn    
    /* Is this an ACK+PSH?
     * If so, we'll handle the HTTP request and reply with the data + FIN+ACK+PSH.
     */
    li $t1, 0x18
    beq $t0, $t1, _tcp_update_handle_tcp_psh    
    /* Is this a FIN+ACK?
     * If so, we'll reply with ACK.
     */
    li $t1, 0x11
    beq $t0, $t1, _tcp_update_handle_tcp_fin    
    /* Ignore anything else. */
    jr $ra

_tcp_update_handle_tcp_syn:
    li $t0, 'S'
    PUTCHAR($t0)    
    /* Add ACK flag. */
    lhu $t0, (ETHER_BUFFER + 46)
    li  $t1, 0x10
    or  $t0, $t0, $t1
    sh  $t0, (ETHER_BUFFER + 46)
    /* Swap dst<->src ports. */
    lhu $t0, (ETHER_BUFFER + 34)
    lhu $t1, (ETHER_BUFFER + 36)
    sh  $t0, (ETHER_BUFFER + 36)
    sh  $t1, (ETHER_BUFFER + 34)
    /* Fill acknowledgement number. */
    lhu $t0, (ETHER_BUFFER + 38)
    lhu $t1, (ETHER_BUFFER + 40)
    sll $t0, $t0, 16
    or  $t0, $t0, $t1
    addiu $t0, $t0, 1
    sh  $t0, (ETHER_BUFFER + 44)
    srl $t0, $t0, 16
    sh  $t0, (ETHER_BUFFER + 42)
    /* Switch Ethernet and IP addresses (dst<->src). */
    move $a0, $ra
    jal swap_ethernet_addresses
    jal swap_ip_addresses
    /* Fix IP checksum. */
    jal do_ip_checksum
    /* Fix TCP checksum. */
    jal do_tcp_checksum
    move $ra, $a0
    /* Send. */
    li $t0, 1
    sb $t0, ETHER_CMD_REGISTER
    jr $ra

_tcp_update_handle_tcp_psh:
    li $t0, 'P'
    PUTCHAR($t0)
    /* Add FIN flag. */
    lhu $t0, (ETHER_BUFFER + 46)
    li  $t1, 0x01
    or  $t0, $t0, $t1
    sh  $t0, (ETHER_BUFFER + 46)
    /* Swap dst<->src ports. */
    lhu $t0, (ETHER_BUFFER + 34)
    lhu $t1, (ETHER_BUFFER + 36)
    sh  $t0, (ETHER_BUFFER + 36)
    sh  $t1, (ETHER_BUFFER + 34)
    /* Fill acknowledgement number. */
    lhu $t0, (ETHER_BUFFER + 38)
    lhu $t1, (ETHER_BUFFER + 40)
    sll $t0, $t0, 16
    or  $t0, $t0, $t1
    lw $t2, ETHER_LENGTH_REGISTER
    li $t1, 34
    subu $t2, $t2, $t1
    lbu $t1, (ETHER_BUFFER + 46)
    srl $t1, $t1, 2
    subu $t2, $t2, $t1
    addu $t0, $t0, $t2
    sh  $t0, (ETHER_BUFFER + 44)
    srl $t0, $t0, 16
    sh  $t0, (ETHER_BUFFER + 42)
    /* Copy request to HTTP buffer. */
    la $t0, (ETHER_BUFFER + 34)
    addu $t0, $t0, $t1
    la $t3, http_buffer
.extern "_request_copy_loop"
_request_copy_loop:
    beq $t2, $0, _request_copy_done
    addi $t2, $t2, -1
    lbu $t4, 0($t0)
    sb  $t4, 0($t3)
    addiu $t0, $t0, 1
    addiu $t3, $t3, 1
    j _request_copy_loop
_request_copy_done:
    /* Switch Ethernet and IP addresses (dst<->src). */
    move $sp, $ra
    jal swap_ethernet_addresses
    jal swap_ip_addresses
    /* Call HTTP server, set packet length, copy response. */
    jal http_handler

    lbu $t1, (ETHER_BUFFER + 46)
    srl $t1, $t1, 2
    addiu $t1, $t1, 34
    addu $t2, $t1, $a1
    sw $t2, ETHER_LENGTH_REGISTER
    addi $t2, $t2, -14
    sh $t2, (ETHER_BUFFER + 16)

    la $t0, ETHER_BUFFER
    addu $t0, $t0, $t1
_response_copy_loop:
    beq $a1, $0, _response_copy_done
    addi $a1, $a1, -1
    lbu $t4, 0($a0)
    sb  $t4, 0($t0)
    addiu $t0, $t0, 1
    addiu $a0, $a0, 1
    j _response_copy_loop
_response_copy_done:
    /* Fix IP checksum. */
    jal do_ip_checksum
    /* Fix TCP checksum. */
    jal do_tcp_checksum
    /* Send. */
    li $t0, 1
    sb $t0, ETHER_CMD_REGISTER
    move $ra, $sp
    jr $ra

_tcp_update_handle_tcp_fin:
    li $t0, 'F'
    PUTCHAR($t0)    
    /* Set ACK flag. */
    li  $t0, 0x10
    sb  $t0, (ETHER_BUFFER + 47)
    /* Swap dst<->src ports. */
    lhu $t0, (ETHER_BUFFER + 34)
    lhu $t1, (ETHER_BUFFER + 36)
    sh  $t0, (ETHER_BUFFER + 36)
    sh  $t1, (ETHER_BUFFER + 34)
    /* Fill acknowledgement and sequence numbers. */
    lhu $t2, (ETHER_BUFFER + 42)
    lhu $t3, (ETHER_BUFFER + 44)
    lhu $t0, (ETHER_BUFFER + 38)
    lhu $t1, (ETHER_BUFFER + 40)
    sll $t0, $t0, 16
    or  $t0, $t0, $t1
    addiu $t0, $t0, 1
    sh  $t0, (ETHER_BUFFER + 44)
    srl $t0, $t0, 16
    sh  $t0, (ETHER_BUFFER + 42)
    sh  $t2, (ETHER_BUFFER + 38)
    sh  $t3, (ETHER_BUFFER + 40)    
    /* Switch Ethernet and IP addresses (dst<->src). */
    move $a0, $ra
    jal swap_ethernet_addresses
    jal swap_ip_addresses
    /* Fix IP checksum. */
    jal do_ip_checksum
    /* Fix TCP checksum. */
    jal do_tcp_checksum
    move $ra, $a0
    /* Send. */
    li $t0, 1
    sb $t0, ETHER_CMD_REGISTER
    jr $ra

/** Swaps Ethernet destination and source address. */
swap_ethernet_addresses:
    lhu $t0, (ETHER_BUFFER + 0)
    lhu $t1, (ETHER_BUFFER + 6)
    sh $t0, (ETHER_BUFFER + 6)
    sh $t1, (ETHER_BUFFER + 0)
    lhu $t0, (ETHER_BUFFER + 2)
    lhu $t1, (ETHER_BUFFER + 8)
    sh $t0, (ETHER_BUFFER + 8)
    sh $t1, (ETHER_BUFFER + 2)
    lhu $t0, (ETHER_BUFFER + 4)
    lhu $t1, (ETHER_BUFFER + 10)
    sh $t0, (ETHER_BUFFER + 10)
    sh $t1, (ETHER_BUFFER + 4)
    jr $ra

/** Swaps IP destination and source address. */
swap_ip_addresses:
    lhu $t0, (ETHER_BUFFER + 26)
    lhu $t1, (ETHER_BUFFER + 30)
    sh $t0, (ETHER_BUFFER + 30)
    sh $t1, (ETHER_BUFFER + 26)
    lhu $t0, (ETHER_BUFFER + 28)
    lhu $t1, (ETHER_BUFFER + 32)
    sh $t0, (ETHER_BUFFER + 32)
    sh $t1, (ETHER_BUFFER + 28)
    jr $ra

/** Recalculate IP header checksum. */
.extern "do_ip_checksum"
do_ip_checksum:
    lhu $t0, (ETHER_BUFFER + 14)
    lhu $t1, (ETHER_BUFFER + 16)
    addu $t0, $t0, $t1
    lhu $t1, (ETHER_BUFFER + 18)
    addu $t0, $t0, $t1
    lhu $t1, (ETHER_BUFFER + 20)
    addu $t0, $t0, $t1
    lhu $t1, (ETHER_BUFFER + 22)
    addu $t0, $t0, $t1
    lhu $t1, (ETHER_BUFFER + 26)
    addu $t0, $t0, $t1
    lhu $t1, (ETHER_BUFFER + 28)
    addu $t0, $t0, $t1
    lhu $t1, (ETHER_BUFFER + 30)
    addu $t0, $t0, $t1
    lhu $t1, (ETHER_BUFFER + 32)
    addu $t0, $t0, $t1
    /* Deal with carry bits. */
    srl $t1, $t0, 16
    addu $t0, $t0, $t1
    /* Store checksum. */
    not $t0, $t0
    sh $t0, (ETHER_BUFFER + 24)
    jr $ra

/** Recalculate TCP header checksum. */
.extern "do_tcp_checksum"
do_tcp_checksum:
    /* Clear old checksum. */
    sh $0, (ETHER_BUFFER + 50)
    /* Pseudo header first.
     * - Source IP
     * - Destination IP
     * - Protocol
     * - TCP length
     */
    lhu $t0, (ETHER_BUFFER + 26)
    lhu $t1, (ETHER_BUFFER + 28)
    addu $t0, $t0, $t1
    lhu $t1, (ETHER_BUFFER + 30)
    addu $t0, $t0, $t1
    lhu $t1, (ETHER_BUFFER + 32)
    addu $t0, $t0, $t1
    lbu $t1, (ETHER_BUFFER + 23)    
    addu $t0, $t0, $t1
    lw $t2, ETHER_LENGTH_REGISTER
    li $t1, 34
    subu $t2, $t2, $t1
    addu $t0, $t0, $t2
    /* Add real header and data.
     * Padding byte is added just in case.
     */
    la $t3, (ETHER_BUFFER + 34)
    addu $t2, $t2, $t3
    sb $0, 0($t2)
_tcp_checksum_more:
    lhu $t1, 0($t3)
    addu $t0, $t0, $t1
    addiu $t3, $t3, 2
    blt $t3, $t2, _tcp_checksum_more
    /* Deal with carry bits. */
    srl $t1, $t0, 16
    addu $t0, $t0, $t1
    /* Store checksum. */
    not $t0, $t0
    sh $t0, (ETHER_BUFFER + 50)
    jr $ra

/* -- TCP/IP CODE ENDS -- */

/* -- HTTP CODE BEGINS -- */

/** Handle an HTTP request.
 * @return number of bytes in response ($a1), pointer to response ($a0).
 */
.extern "http_handler" 
http_handler:
    li $t0, 'H'
    PUTCHAR($t0)
    /* Is this a GET request? */
    lw $t0, http_buffer
    li $t1, 0x47455420 /* "GET " */
    beq $t0, $t1, _http_handler_get
    /* Is this a POST request? */
    li $t1, 0x504F5354
    beq $t0, $t1, _http_handler_exit
    /* It isn't. */
    la $a0, http_bad_request
    li $a1, HTTP_BAD_REQUEST_STRING_LEN
    jr $ra
_http_handler_get:
    /* Find first ' ' or '\n' after "GET ", and replace it with '\0'.
     * This '\0' terminates the location string.
     */
    la $t0, (http_buffer + 3)
    li $t2, ' '
    li $t3, '\n'
_http_handler_terminate_loop:
    addiu $t0, $t0, 1
    lbu $t1, 0($t0)
    beq $t1, $t2, _http_handler_terminate_loop_end
    bne $t1, $t3, _http_handler_terminate_loop
_http_handler_terminate_loop_end:
    sb $0, 0($t0)
    /* The location string is now terminated. */
    /* Print location! */
    move $t0, $ra
    la $a0, (http_buffer + 4)
    jal putstring
    move $ra, $t0
    /* Home page request? */
    lbu $a0, (http_buffer + 5)
    beq $a0, $0, _http_handler_home
    /* Not found. */
    la $a0, http_not_found
    li $a1, HTTP_NOT_FOUND_STRING_LEN
    jr $ra
_http_handler_home:
    la $a0, http_home
    li $a1, HTTP_HOME_STRING_LEN
    jr $ra
_http_handler_exit:
    la $a0, http_shutdown
    li $a1, HTTP_SHUTDOWN_STRING_LEN
    la $sp, _http_exit
    jr $ra
_http_exit:
    /* Print startup message. */
    la $a0, shutdown_msg
    jal putstring
    EXIT();

/* -- HTTP CODE ENDS -- */

/** Startup message. */
startup_msg:
    .asciiz "HTTPAsm - Daniel Kasza <daniel@kasza.hu>\n"
/** Shutdown message. */
shutdown_msg:
    .asciiz "\nThank you for trying HTTPAsm!\n"

/** HTTP request buffer.
 * TCP code fills it with the request.
 */
http_buffer:
    .align 4
    .space HTTP_BUFFER_SIZE
    /* Guard against bad request that does not contain spaces. */
    .ascii " "

/* -- HTTP responses begin -- */

http_bad_request:
    .ascii HTTP_BAD_REQUEST_STRING
http_not_found:
    .ascii HTTP_NOT_FOUND_STRING
http_home:
    .ascii HTTP_HOME_STRING
http_shutdown:
    .ascii HTTP_SHUTDOWN_STRING

/* -- HTTP responses end -- */
    