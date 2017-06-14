#!bin/python

def eddy_rotate_bvecs(in_bvec, eddy_params):
    """
    Rotates the input bvec file accordingly with a list of parameters sourced
    from ``eddy``, as explained `here
    <http://fsl.fmrib.ox.ac.uk/fsl/fslwiki/EDDY/Faq#Will_eddy_rotate_my_bevcs_for_me.3F>`_.
    """
    import os
    import numpy as np
    from math import sin, cos

    name, fext = os.path.splitext(os.path.basename(in_bvec))
    if fext == '.gz':
        name, _ = os.path.splitext(name)
    out_file = os.path.abspath('%s_rotated.bvec' % name)
    bvecs = np.loadtxt(in_bvec,usecols =(0,1,2))
    new_bvecs = []
    params = np.loadtxt(eddy_params)

    if len(bvecs) != len(params):
        print'bvecs len={0}, eddy len={1}'.format(len(bvecs),len(params))
        raise RuntimeError(('Number of b-vectors and rotation '
                           'matrices should match.'))

    for bvec, row in zip(bvecs, params):
        if np.all(bvec == 0.0):
            new_bvecs.append(bvec)
        else:
            ax = row[3]
            ay = row[4]
            az = row[5]

            Rx = np.array([[1.0, 0.0, 0.0],
                          [0.0, cos(ax), -sin(ax)],
                          [0.0, sin(ax), cos(ax)]])
            Ry = np.array([[cos(ay), 0.0, sin(ay)],
                          [0.0, 1.0, 0.0],
                          [-sin(ay), 0.0, cos(ay)]])
            Rz = np.array([[cos(az), -sin(az), 0.0],
                          [sin(az), cos(az), 0.0],
                          [0.0, 0.0, 1.0]])
            R = Rx.dot(Ry).dot(Rz)

            invrot = np.linalg.inv(R)
            newbvec = invrot.dot(bvec)
            new_bvecs.append((newbvec/np.linalg.norm(newbvec)))
    np.savetxt(out_file, np.array(new_bvecs), fmt='%0.15f')
    return out_file

import os
eddy=os.environ["eddy"]
bvec_Pos=os.environ["bvec_Pos"]

eddy_rotate_bvecs(bvec_Pos, eddy)
