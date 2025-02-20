package org.openxava.web.filters;

import java.io.*;

import javax.servlet.*;
import javax.servlet.annotation.*;
import javax.servlet.http.*;

import org.openxava.util.*;
import org.openxava.web.*;

/**
 * 
 * @since 7.1
 * @author Javier Paniza
 */

@WebFilter("/*") // If you change this pass the ZAP test again
public class ContentSecurityPolicyFilter implements Filter {

    private static String mapsTileProviderURL; 

	public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
    	// If you change this pass the ZAP test again
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        String policy = "default-src 'self'; script-src 'self' 'nonce-" + 
        	Nonces.get(request) + 
        	"' 'unsafe-eval' " + 
        	getTrustedHostsForScripts() + 
        	"; style-src 'self' 'nonce-" + 
        	Nonces.get(request) +
        	"' " + 
        	getTrustedHostsForStyles() + 
        	"; img-src 'self' data: blob: " + 
        	getMapsTileProviderURL() + getTrustedHostsForImages() +
        	"; worker-src 'self' blob:; frame-src 'self' " +
        	getTrustedHostsForFrames() +
        	"; frame-ancestors 'self'; form-action 'self'; font-src 'self' data:";        
        httpResponse.setHeader("Content-Security-Policy", policy);
        httpResponse.setHeader("X-Content-Type-Options", "nosniff");
        chain.doFilter(request, response);
    }
	
	public void init(FilterConfig cfg) throws ServletException { // In order to work with Tomcat 8.x		
	}
	
	public void destroy() { // In order to work with Tomcat 8.x
	}
	
	private String getTrustedHostsForImages() { 
		return XavaPreferences.getInstance().getTrustedHostsForImages().replace(",", " ");
	}
	
	private String getTrustedHostsForScripts() {
		return XavaPreferences.getInstance().getTrustedHostsForScripts().replace(",", " ");
	}
	
	private String getTrustedHostsForStyles() { 
		return XavaPreferences.getInstance().getTrustedHostsForStyles().replace(",", " ");
	}	
	
	private String getTrustedHostsForFrames() { 
		return XavaPreferences.getInstance().getTrustedHostsForFrames().replace(",", " ");
	}
    
    private static String getMapsTileProviderURL() { 
    	if (mapsTileProviderURL == null) {
    		mapsTileProviderURL = getBaseURL(XavaPreferences.getInstance().getMapsTileProvider()) + " ";  
    	}
    	return mapsTileProviderURL;    	
    }
    
    private static String getBaseURL(String url) { 
        String[] tokens = url.split("/");
        return tokens[0] + "//" + tokens[2] + "/" ;
    }

}
