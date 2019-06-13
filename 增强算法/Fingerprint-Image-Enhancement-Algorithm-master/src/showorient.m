function showorient(orient, space)
    
    [o_rows, o_cols] = size(orient);
    
    o_len = 0.8*space;
 
    s_orient = orient(space:space:o_rows-space, space:space:o_cols-space);
 
    x_off = o_len/2*cos(s_orient);
    y_off = o_len/2*sin(s_orient);    
    
    [m_x,m_y] = meshgrid(space:space:o_cols-space, space:space:o_rows-space);
    
    m_x = m_x - x_off;
    m_y = m_y - y_off;
    
    m_u = x_off*2;
    m_v = y_off*2;
    
    quiver(x,y,m_u,m_v,0,'.','linewidth',1, 'color','r');
