/*************************************************************************
 *                                                                       *
 *  EJBCA Community: The OpenSource Certificate Authority                *
 *                                                                       *
 *  This software is free software; you can redistribute it and/or       *
 *  modify it under the terms of the GNU Lesser General Public           *
 *  License as published by the Free Software Foundation; either         *
 *  version 2.1 of the License, or any later version.                    *
 *                                                                       *
 *  See terms of license at gnu.org.                                     *
 *                                                                       *
 *************************************************************************/

package org.ejbca.core.ejb;

import java.util.List;

import javax.naming.NamingEnumeration;
import javax.naming.NamingException;
import javax.naming.directory.SearchControls;
import javax.naming.directory.SearchResult;

import org.cesecore.config.MSAutoEnrollmentSettingsTemplate;
import org.ejbca.core.protocol.msae.ADConnectionSingletonLocal;
import org.ejbca.core.protocol.msae.LDAPException;

public class ADConnectionSingletonBean implements ADConnectionSingletonLocal {

    @Override
    public void updateConnectionProperties() throws LDAPException {
        throw new UnsupportedOperationException("ADConnection calls are only supported in EJBCA Enterprise");
        
    }

    @Override
    public NamingEnumeration<SearchResult> getEntryNamedContext(String searchBase, String searchFilter, SearchControls searchCtls, String domain)
            throws NamingException {
        throw new UnsupportedOperationException("ADConnection calls are only supported in EJBCA Enterprise");
    }

    @Override
    public void testConnection(String domain, int port, String loginDN, String loginPassword, boolean useSSL) throws LDAPException {
        throw new UnsupportedOperationException("ADConnection calls are only supported in EJBCA Enterprise");
        
    }

    @Override
    public List<MSAutoEnrollmentSettingsTemplate> getCertificateTemplateSettings() {
        throw new UnsupportedOperationException("ADConnection calls are only supported in EJBCA Enterprise");
    }

    @Override
    public NamingEnumeration<SearchResult> getEntryNamedContext(String searchBase, String searchFilter, SearchControls searchCtls) {
        throw new UnsupportedOperationException("ADConnection calls are only supported in EJBCA Enterprise");
    }

}
