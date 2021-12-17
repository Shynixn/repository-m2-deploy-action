package com.github.shynixn.helloworld;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Base64;

public class HelloWorld {
    public void say() throws IOException {
        byte[] data = Files.readAllBytes(Paths.get("F:\\Archive\\Z_\\Dokumente\\Keys\\2021-Latest Private PublicKey\\secret-base64-4.asc"));


    }

    public static void main(String[] args) throws IOException {
        byte[] data = Files.readAllBytes(Paths.get("F:\\Archive\\Z_\\Dokumente\\Keys\\2021-Latest Private PublicKey\\secret-base64-4.asc"));

       Files.writeString(Paths.get("F:\\Archive\\Z_\\Dokumente\\Keys\\2021-Latest Private PublicKey\\secret-base64-5.asc"), Base64.getEncoder().encodeToString(data));
    }
}
