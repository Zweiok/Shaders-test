using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GroundShaderController : MonoBehaviour
{
    [SerializeField] private MeshRenderer groundMesh;
    [SerializeField] private Material groundMat;
    private int matCount = 1;

    public void MakeHole(Vector2 position)
    {
        matCount++;
        List<Material> prev = new List<Material>(groundMesh.materials);
        groundMesh.materials = new Material[matCount];
        Material m = Instantiate(groundMat);
        prev.Add(m);
        m.SetVector("_DistorionOffset", new Vector4(position.x, position.y, 0, 0));
        m.SetFloat("_EnableWholeTexture", 0);
        m.SetFloat("_EnableDistortion", 1);

        groundMesh.materials = prev.ToArray();
    }
}
