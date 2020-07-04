---
layout: posts
title: Licensing using XML digital signing.
date: '2012-08-14T09:00:00.000-07:00'
author: awalsh128
tags:
- security
- ".NET"
- XML
modified_time: '2012-10-03T13:43:30.647-07:00'
blogger_id: tag:blogger.com,1999:blog-6363087137667886940.post-7733218171039693768
blogger_orig_url: https://awalsh128.blogspot.com/2012/08/licensing-using-xml-digital-signing.html
---

### Motivation

One of the main concerns in any licensing implementation is that
authored license files are coming from the trusted authority (ie. your
company) and not some third party. This can be accomplished in software
by encrypting and decrypting the license with a [single
key](http://en.wikipedia.org/wiki/Symmetric-key_algorithm), but
symmetric [key storage](http://en.wikipedia.org/wiki/Key_management) can
be cumbersome and have added complexity.

[Assymetric
cryptography](http://en.wikipedia.org/wiki/Public-key_cryptography), on
the other hand, allows for two keys: a private one to author files with
and a public one to verify its authenticity. This is well suited for
licensing, where we want to ensure that the authored license has not
been altered in anyway and the content can be relied on.

### Implementation

I ran across [a great
article](http://www.codeproject.com/Articles/4940/Using-XML-Digital-Signatures-for-Application-Licen%20)
that details the use of XML digital signatures in the .NET framework. It
describes the type of digital signatures that can be implemented and
lays out the classes and methods needed to author and verify license
files.

This specific implementation allows for an: authentication key to
compare against some unique value tying the license to the system,
expiration date to set a time span on the software use and set of
available features the user is authorized for.

Base Class
----------

This forms the runtime object representation of the license and will be
inherited by the license reader and writer.

``` csharp
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Text;
using System.Security;
using System.Security.Cryptography;
using System.Security.Cryptography.Xml;
using System.Xml;

namespace Licensing
{

public abstract class LicenseBase
{ 
 private byte[] _authenticationKey; 
 private DateTime _expiration; 
 private List _features;
    private int _id;

 public byte[] AuthenticationKey {
  get { return _authenticationKey; }
  protected set { _authenticationKey = value; }
 }
 public DateTime Expiration {
  get { return _expiration; }
  protected set { _expiration = value; }
 }
 public int Id {
  get { return _id; }
        protected set { _id = value; }
 }
 protected List Features {
        get { return _features; }
 } 

 public LicenseBase()
 {
  _features = new List();
 }

    public void Clear()
    {
        _id = 0;
        _authenticationKey = null;
        _features.Clear();
    }
}

}
```

Writer Class
------------

This class will be used internally to author the license files that will
be distributed with the released software. Note that the private key is
added as an embedded resource in the project and should not be
distributed since the public key can be derived from it.

``` csharp
using System;
using System.IO;
using System.Security;
using System.Security.Cryptography;
using System.Security.Cryptography.Xml;
using System.Text;
using System.Xml;

namespace Licensing
{
    class License : LicenseBase
    {

        License(int id, byte[] authenticationKey, DateTime expiration, string[] features)
        {
            this.AuthenticationKey = authenticationKey;            
            this.Expiration = expiration;
            this.Id = id;
            this.Features.AddRange(features);
        }

        /// 
        /// Generates a key pair for digital signing and verification.
        /// 
        /// 
        /// 
        static internal void GenerateAssymetricKeys()
        {
            string datestamp = null;
            StreamWriter output = null;
            RSA key = RSA.Create();
            key.KeySize = 1024;

            datestamp = DateTime.UtcNow.ToString("yyyyMMdd");

            // Generate private key to only be used internally (DO NOT DISTRIBUTE).
            output = File.CreateText("private-" + datestamp + ".key");
            output.Write(key.ToXmlString(true));
            output.Close();

            // Generate public key to be used by customers (distribute).
            output = File.CreateText("public-" + datestamp + ".key");
            output.Write(key.ToXmlString(false));
            output.Close();
        }

        /// 
        /// Digitally sign an XML document.
        /// 
        /// The XML document to sign.
        /// The private key to sign it with.    
        /// 
        private static void _SignXmlDocument(System.Xml.XmlDocument document, RSA privateKey)
        {
            SignedXml signedDocument = new SignedXml(document);
            signedDocument.SigningKey = privateKey;
            signedDocument.SignedInfo.CanonicalizationMethod = SignedXml.XmlDsigCanonicalizationUrl;

            // Add reference to XML data
            Reference @ref = new Reference("");
            @ref.AddTransform(new XmlDsigEnvelopedSignatureTransform(false));
            signedDocument.AddReference(@ref);

            // Build the signature.
            signedDocument.ComputeSignature();

            // Attach the signature to the XML document.
            XmlElement signature = signedDocument.GetXml();
            document.DocumentElement.AppendChild(signature);
        }

        /// 
        /// Write the contents and digitally sign the document.
        /// 
        /// The file path to the digitally signed document.
        public void WriteDocument(string filepath)
        {
            XmlDocument document = new XmlDocument();
            document.AppendChild(document.CreateXmlDeclaration("1.0", "UTF-8", null));

            XmlElement root = document.CreateElement("License");
            document.AppendChild(root);

            XmlElement id = document.CreateElement("Id");
            id.InnerText = this.Id.ToString();
            root.AppendChild(id);

            XmlElement authenticationKey = document.CreateElement("AuthenticationKey");            
            authenticationKey.InnerText = Convert.ToBase64String(this.AuthenticationKey);
            root.AppendChild(authenticationKey);

            XmlElement expiration = document.CreateElement("Expiration");
            expiration.InnerText = this.Expiration.ToString();
            root.AppendChild(expiration);

            XmlElement options = document.CreateElement("Features");
            XmlElement featureItem = null;
            foreach (string feature in this.Features)
            {
                featureItem = document.CreateElement("Feature");
                featureItem.InnerText = feature;
                options.AppendChild(featureItem);
            }
            root.AppendChild(options);

            XmlElement publickey = document.CreateElement("Certificate");
            publickey.SetAttribute("DateCode", KeyCreationDateCode);
            publickey.InnerXml = File.ReadAllText(PublicKeyFilename);
            root.AppendChild(publickey);

            RSA privateKey = RSA.Create();
            privateKey.FromXmlString(Licensing.Properties.Resources.privatekey);
            _SignXmlDocument(document, privateKey);

            File.WriteAllText(filepath, document.InnerXml);            
        }

    }
}
```

Reader Class
------------

This class will be used in the field to verify the license files that
will be distributed with the released software. It is best to wrap the
license read and authenticate methods in try-catch blocks since they
represent exceptional behavior that fall outside the post-conditions of
the method. Handling the exceptions will allow for better error
reporting in the field so you can decide what information you will share
with the end user (eg. bad authentication key, malformed/tampered
licenses). Note again that the public key is an embedded resource for
the project. It should never be distributed with the license since an
attacker could generate their own keypair and envelope their own public
key, with signature, in the license.

``` csharp
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Text;
using System.Security;
using System.Security.Cryptography;
using System.Security.Cryptography.Xml;
using System.Xml;

namespace Licensing
{
    class LicenseReader : LicenseBase
    {
        LicenseReader()
        {
        }

        public void Authenticate()
        {
            // Check the hardware key value against the AuthenticationKey        
            if (!_AuthenticationKeyMatches(hardwareKey))
                throw new LicenseAuthenticationException("The license failed to authenticate the hardware key.");

            // ... or check some node locking ID (eg. MAC ID, hard drive serial number) against the AuthenticationKey.
            if (!_AuthenticationKeyMatches(nodeLockedId))
                throw new LicenseAuthenticationException("The license failed to authenticate the node locked ID.");

            if (this.Expiration > DateTime.UtcNow)
                throw new LicenseAuthenticationException("The license has expired.");
        }

        /// 
        /// Compare byte array against authentication key byte array.
        /// 
        /// Byte array to compare against.
        /// True if a match, else false.
        private bool _AuthenticationKeyMatches(byte[] compare)
        {
            if (this.AuthenticationKey == null)
                return false;

            int upperBound = Math.Min(this.AuthenticationKey.Length, compare.Length);
            for (int i = 0; i < upperBound; i++)
            {
                if (this.AuthenticationKey[i] != compare[i])
                    return false;
            }
            return true;
        }

        public bool IsFeature(string featureName)
        {
            return this.Features.Contains(featureName);
        }

        /// 
        /// Read the digitally signed document and load its contents.
        /// 
        /// The file path to the digitally signed document.
        protected virtual void ReadDocument(string filepath)
        {
            this.Clear();

            XmlDocument document = new XmlDocument();
            document.Load(filepath);

            RSA publicKey = RSA.Create();
            publicKey.FromXmlString(Licensing.Properties.Resources.publickey);

            if (_VerifyXmlDocument(document, publicKey))
            {
                this.Id = int.Parse(document.SelectSingleNode("//License/Id").InnerText);
                this.AuthenticationKey = Convert.FromBase64String(document.SelectSingleNode("//License/AuthenticationKey").InnerText);
                this.Expiration = DateTime.Parse(document.SelectSingleNode("//License/Expiration").InnerText);

                XmlNodeList features = document.SelectNodes("//License/Features/Feature");
                foreach (XmlNode feature in features)
                {
                    this.Features.Add(feature.InnerText);
                }
            }

        }

        /// 
        /// Verify the digital signature of an XML document.
        /// 
        /// The XML document containing the signature.
        /// The public key to verify signature authenticity.
        /// True if the signature is authentic, else false.
        /// 
        private bool _VerifyXmlDocument(XmlDocument document, RSA publicKey)
        {
            SignedXml signedDocument = new SignedXml(document);
            try
            {
                XmlNode signature = document.GetElementsByTagName("Signature", SignedXml.XmlDsigNamespaceUrl)[0];
                signedDocument.LoadXml((XmlElement)(signature));
            }
            catch
            {
                return false;
            }
            return signedDocument.CheckSignature(publicKey);
        }

    }
}
```

### Additions & Caveats

Symmetric encryption could also be used to hinder casual viewing of the
license file. The issue of symmetric key storage must be revisited but
will no longer be critical to maintaining the integrity of the license
files.

Strong naming of the license reading assembly is encouraged to prevent
dissasembly and re-embedding of an attacker\'s own public key. Although,
this is by no means an attack-proof method since [strong naming can be
removed](http://www.codeproject.com/Articles/15374/Removing-Strong-Signing-from-assemblies-at-file-le)
by changing information in the [CLI
header](http://www.ntcore.com/Files/dotnetformat.htm) of the portable
executable (PE). Even if the application was able to secure the public
key outside the application in a
[PKI](http://en.wikipedia.org/wiki/Public_key_infrastructure), there is
still the issue of code injection or recompilation once strong naming is
stripped. Indirection of the public key or obfuscation of the assembly
can also help but is [not a reliable security
measure](http://csrc.nist.gov/publications/secpubs/faq-sec.txt).
